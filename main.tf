// Find the latest available Canonical, Ubuntu, 20.04 LTS, arm64 focal AMI
data "aws_ami" "ubuntu" {
  // Canonical Owner
  owners = ["099720109477"]

  // Ubuntu 20.04 LTS AMI
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  most_recent = true
}

// Create AWS EC2 instance for webserver demo
resource "aws_instance" "demoInstance" {
  ami = data.aws_ami.ubuntu.id

  // Small instance for demo
  instance_type = "t2.micro"

  tags = {
    Name  = "webserver"
    Value = "demo"
  }

  vpc_security_group_ids = [aws_security_group.demoSecG.id]

  subnet_id = aws_subnet.demoSubN.id

  associate_public_ip_address = true

  user_data = file("install_and_run.sh")

  iam_instance_profile = aws_iam_instance_profile.demoProfile.name

  /* 
  The instance depends on AWS S3 Bucket, for demo purposes only we're
  hosting a web page in the S3 Bucket. When connecting
  to the public IP of the instance, the web page should be served.
  This demonstrates that the instance has been granted access to the
  S3 Bucket through an IAM Role.
  */
  depends_on = [
    aws_s3_bucket_object.webpage,
  ]
}

// Exclude us-west-2d since it does not support instance_type = "t2.micro"
data "aws_availability_zones" "available" {
  state = "available"
  exclude_names = ["us-west-2d"]
}

// Simple VPC, enabling DNS hostnames optional for demo
resource "aws_vpc" "demoVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

// VPC subnet on first available AZ
resource "aws_subnet" "demoSubN" {
  vpc_id            = aws_vpc.demoVPC.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

// Security Group for the instance
resource "aws_security_group" "demoSecG" {
  vpc_id = aws_vpc.demoVPC.id

  // Allow inbound access on port 80 for HTTP
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

// Internet Gateway
resource "aws_internet_gateway" "demoGW" {
  vpc_id = aws_vpc.demoVPC.id
}

resource "aws_route_table" "demoRT" {
  vpc_id = aws_vpc.demoVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demoGW.id
  }
}

resource "aws_route_table_association" "demoRTA" {
  subnet_id      = aws_subnet.demoSubN.id
  route_table_id = aws_route_table.demoRT.id
}


// IAM role that grants access to AWS S3 Bucket

// Create AWS S3 Bucket for webserver demo
resource "aws_s3_bucket" "demos3" {
  bucket        = "webserverdemos3bucket"
  acl           = "private"
  force_destroy = true
}

// Upload web page as an object to S3 Bucket
resource "aws_s3_bucket_object" "webpage" {
  bucket = aws_s3_bucket.demos3.id
  key    = "index.html"
  acl    = "private"
  source = "index.html"
  etag   = filemd5("index.html")
}

// Create IAM role
resource "aws_iam_role" "demoRole" {
  name               = "webserverdemo-role"
  assume_role_policy = data.aws_iam_policy_document.assumeRole.json
}

data "aws_iam_policy_document" "assumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

// Create IAM instance profile attached to previously defined role
resource "aws_iam_instance_profile" "demoProfile" {
  name = "webserdemoProfile"
  role = aws_iam_role.demoRole.name
}

// Create Role policy for previously defined role
resource "aws_iam_role_policy" "demoPolicy" {
  name   = "webserverdemoiam-rw"
  policy = data.aws_iam_policy_document.demoAll.json
  role   = aws_iam_role.demoRole.id
}

data "aws_iam_policy_document" "demoAll" {
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.demos3.arn, "${aws_s3_bucket.demos3.arn}/*"]
    effect    = "Allow"
  }
}



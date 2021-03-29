/*
Always a good idea not to store the Terraform state file locally.
One possibility is to designate a previously created S3 Bucket as 
the terraform state backend for the state as follows:
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
*/

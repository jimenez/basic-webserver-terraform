# basic-webserver-terraform

Terraform config to demo:

- AWS EC2 instance based on Ubuntu image
- Docker and AWS cli install and run on instance
- AWS S3 private Bucket
- AWS IAM Role to grant instance access to S3 Bucket
- Webserver Docker image run with mounted web page fetched from S3 Bucket

## Requirements

- Terraform
- AWS credentials

## Run

Initialize the working Terraform directory by running `terraform init`.
Export AWS credentials to your environment for a more convenient experience.
Note that exporting the AWS region is optional, a default region is set to: us-west-2 on the vars file.

```sh
$ export TF_VAR_aws_region=<REGION: e.g.: us-east-1>
$ export TF_VAR_aws_access_key_id=<KEY>
$ export TF_VAR_aws_secret_access_key=<SECRET>
```

Run Terraform plan command to create an execution plan and check if this matches expectations.

```sh
$ terraform plan -out plan.out
```

Run Terraform apply.

```sh
$ terraform apply plan.out
```

The output should include both the public DNS and IP, where the webserver should be reacheable, please allow some time
for Docker and the AWS cli to be installed, and for the container to run.
```sh
$ curl <PUBLIC_IP>
```

## Destroy

Run `terraform destroy` to delete all the resources. Note that the AWS S3 Bucket is set to be force destroyed.

## State

The terraform state will be stored locally by default, it is recommended that if this demo is used for production the state be stored in a decentralized way.

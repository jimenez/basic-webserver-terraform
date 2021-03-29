#! /bin/bash

# Get Docker install script
curl -fsSL https://get.docker.com -o get-docker.sh

# Run Docker install script
sudo sh get-docker.sh

# Install AWS CLI
sudo apt-get install -y awscli

# Create demo folder for website
mkdir /tmp/website

# Get web page from S3 Bucket
aws s3 cp s3://webserverdemos3bucket/index.html /tmp/website

# Run Docker container from Nginx image mounting demo folder to serve webpage on port 80
sudo docker run -d --restart=always --name=webserverdemo -p 80:80 -v /tmp/website:/usr/share/nginx/html:ro nginx
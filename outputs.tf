output "public-ip" {
  value = aws_instance.demoInstance.public_ip
}

output "public-dns" {
  value = aws_instance.demoInstance.public_dns
}
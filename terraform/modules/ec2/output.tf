output "instance-id" {
  description = "the instance id "
  value       = aws_instance.my-ec2.id
}
output "public_ip" {
  value = aws_instance.my-ec2.public_ip
  description = "Public IP address of the EC2 instance"
}

output "private_ip" {
  value = aws_instance.my-ec2.private_ip
  description = "Private IP address of the EC2 instance"
}
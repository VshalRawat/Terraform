output "security_group" {
  description = "Shows the security group name."
  value = aws_security_group.creating_security_group.name
}

output "instance_name" {
  description = "ID of the vishal EC2 instance"
  value = aws_instance.creating_ec2.tags.Name
}

output "instance_id" {
  description = "ID of the vishal EC2 instance"
  value = aws_instance.creating_ec2.id
}


output "instance_type" {
  description = "the type of EC2 instance"
  value = aws_instance.creating_ec2.instance_type
}
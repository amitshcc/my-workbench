output "PrivateInstanceIPs" {
  value = [
    for instance in aws_instance.private_instances : instance.private_ip
  ]
}

output "PublicInstanceIPs" {
  value = [
    for instance in aws_instance.public_instances : instance.public_ip
  ]
}
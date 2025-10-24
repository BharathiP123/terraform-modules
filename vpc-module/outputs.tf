output "vpcid" {
    value = aws_vpc.main.id
}

output "public_subnet_id" {
    value = aws_subnet.pbulicsubnets[*].id
  
}

output "private_subnet_id" {
    value = aws_subnet.private_subnets[*].id
  
}
output "database_subnet_id" {
    value = aws_subnet.databasesubnets[*].id
  
}


output "azs_info"{
    value = data.aws_availability_zones.available
}
output "vpc_id"{
    value = aws_vpc.main.id
}
output "subnet_public"{
    value = aws_subnet.public[*].id
}
output "subnet_private"{
    value = aws_subnet.private[*].id
}
output "subnet_db"{
    value = aws_subnet.db[*].id
}
output "vpc_id" {
    value = aws_vpc.deveploment_vpc.id
}
output "public_subnet_id" {
    value = aws_subnet.public_subnet[*].id
}
output "private_subnet_id" {
    value = aws_subnet.private_subnet[*].id
}
output "internet_gateway_id" {
    value = aws_internet_gateway.igw.id
}
output "nat_gateway_id" {
    value = aws_nat_gateway.deveploment_NAT[*].id
}
output "DB_subnet_id" {
    value = aws_subnet.DB_subnet[*].id
}
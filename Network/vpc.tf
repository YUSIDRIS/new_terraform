resource "aws_vpc" "deveploment_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-VPC"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.deveploment_vpc.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}
# this the availability zones
data "aws_availability_zones" "AZ" {}

resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidr) 
  vpc_id     = aws_vpc.deveploment_vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PUBLIC-${count.index+1}-SUBNET"
  }
}

resource "aws_subnet" "private_subnet" {
  count      = length(var.public_subnet_cidr) 
  vpc_id     = aws_vpc.deveploment_vpc.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "PRIVATE-${count.index+1}-SUBNET"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.deveploment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "${var.project_name}-PUBLIC_ROUTE_TABLE"
  }
}

resource "aws_route_table_association" "associate_route_table" {
  count      = length(var.public_subnet_cidr) 
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_nat_gateway" "deveploment_NAT" {
  count =length(var.private_subnet_cidr)   
  depends_on = [
    aws_eip.nat_ip
  ]
  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.nat_ip[count.index].id
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = "${var.project_name}-${count.index+1}-NAT"
  }
}

resource "aws_eip" "nat_ip" {
  count      = length(var.private_subnet_cidr) 
  depends_on = [aws_internet_gateway.igw]
  tags = {
    "Name" = "nat_ip_${count.index+1}"
  }
}

resource "aws_route_table" "NAT-Gateway-RT" {
    count = length(var.private_subnet_cidr)
    depends_on = [
    aws_nat_gateway.deveploment_NAT
  ]

  vpc_id = aws_vpc.deveploment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.deveploment_NAT[count.index].id
  }

  tags = {
     Name = "${var.project_name}-${count.index+1}- NAT-RT"
  }

}
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
   count =  length(var.private_subnet_cidr)
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.NAT-Gateway-RT[count.index].id
}
resource "aws_subnet" "DB_subnet" {
  count      = length(var.DB_subnet_cidr) 
  vpc_id     = aws_vpc.deveploment_vpc.id
  cidr_block = var.DB_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "DB-${count.index+1}-SUBNET"
  }
}


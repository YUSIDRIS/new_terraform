data "terraform_remote_state" "Network" {
  backend = "s3"
  config = {
    bucket = "idristerraformstate1"
    key    = "Network.statefile"
    region = "us-west-2"
  }
}
data "aws_ami" "amazon_image" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*.0-kernel-6.1-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_security_group" "internetLB" {
  name        = "INTERNETLB"
  description = "Allow Http traffic from internetLB to everyone"
  vpc_id      = data.terraform_remote_state.Network.outputs.vpc_id

  ingress {
    description = "http to everyone"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "INTERNETLB ${var.project_name}-SG"
  }
}

output "INTERNETLB_SG" {
  value = aws_security_group.internetLB.id
}




resource "aws_security_group" "frontendSG" {
  name        = "backend security group"
  description = "Allow traffic to load balance from port 3000"
  vpc_id      = data.terraform_remote_state.Network.outputs.vpc_id
  ingress {
    description = "internet load balancer to port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.internalLB.id]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "frontend${var.project_name}-SG"
  }
}

output "frontend_Sg_id" {
  value = aws_security_group.frontendSG.id
}

resource "aws_security_group" "internal_load_balancer_SG" {
  name        = "internal load balancer security group"
  description = "Allow traffic to public subnet ec2 from internal load balancer"
  vpc_id      = data.terraform_remote_state.Network.outputs.vpc_id
  ingress {
    description = "traffic to public subnet from internet load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.frontendSG.id]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "frontend${var.project_name}-SG"
  }
}

output "internal_load_balancer_SG_id" {
  value = aws_security_group.internal_load_balancer_SG.id
}


resource "aws_security_group" "backendSG" {
  name        = "backend security group"
  description = "Allow traffic to internal load balance from port 4000"
  vpc_id      = data.terraform_remote_state.Network.outputs.vpc_id
  ingress {
    description = "internet load balancer to port 4000"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.internal_load_balancer_SG.id]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "backend${var.project_name}-SG"
  }
}

output "backend_Sg_id" {
  value = aws_security_group.backendSG.id
}

resource "aws_security_group" "databaseSG" {
  name        = "database security group"
  description = "Allow access from backend to the database"
  vpc_id      = data.terraform_remote_state.Network.outputs.vpc_id
  ingress {
    description = "allow access to port 3306 from backend "
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.backendSG.id]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "databaseend${var.project_name}-SG"
  }
}

output "database_Sg_id" {
  value = aws_security_group.databaseSG.id
}

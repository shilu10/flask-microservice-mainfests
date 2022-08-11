#######################################
# Vpc
#######################################

locals {
  vpc_id = aws_vpc.cluster_vpc.id
}

resource "aws_vpc" "cluster_vpc" {
  cidr_block         = var.cluster_vpc_cidr_block
  enable_dns_support = true

  tags = {
    Name = "cluster_vpc"
  }
}

#######################################
# Subnets
#######################################

resource "aws_subnet" "cluster_public_subnets" {
  count                   = length(var.cluster_public_subnets) > 0 ? length(var.cluster_public_subnets) : 0
  vpc_id                  = aws_vpc.cluster_vpc.id
  cidr_block              = var.cluster_public_subnets[count.index]
  availability_zone       = var.cluster_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "cluster_public_subnets"
  }
}

resource "aws_subnet" "cluster_private_subnets" {
  count             = length(var.cluster_private_subnets)  > 0 ? length(var.cluster_private_subnets) : 0
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = var.cluster_private_subnets[count.index]
  availability_zone = var.cluster_azs[count.index]

  tags = {
    Name = "cluster_private_subnets"
  }
}

#######################################
# Security Groups
#######################################

resource "aws_security_group" "cluster_security_group" {
  name        = var.cluster_security_group_name
  description = var.security_group_description
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = var.ingress

    content {
      description      = lookup(ingress, "description", null)
      from_port        = lookup(ingress, "from_port", 0)
      to_port          = lookup(ingress, "to_port", 0)
      protocol         = lookup(ingress, "protocol", -1)
      cidr_blocks      = compact(split(",", lookup(ingress, "cidr_blocks", "")))
    }
    }

    dynamic "egress" {
      for_each = var.egress

      content {
         description      = lookup(egress, "description", null)
      from_port        = lookup(egress, "from_port", 0)
      to_port          = lookup(egress, "to_port", 0)
      protocol         = lookup(egress, "protocol", -1)
      cidr_blocks      = compact(split(",", lookup(egress, "cidr_blocks", "")))
      }

    }
  }



#######################################
# Internet Gateway
#######################################

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = local.vpc_id
  tags = {
    Name = "Internet Gateway of Vpc Cluster"
  }
}

#######################################
# Route Tables
#######################################

resource "aws_route_table" "public_route_table" {
  vpc_id = local.vpc_id
  tags = {
    Name = "Public Route Table"
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id = local.vpc_id
  tags = {
    Name = "Private Route table"
  }
}

#######################################
# Route Table Association
#######################################

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.cluster_public_subnets)  > 0 ? length(aws_subnet.cluster_public_subnets) : 0
  subnet_id      = aws_subnet.cluster_public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.cluster_private_subnets) > 0 ? length(aws_subnet.cluster_private_subnets) : 0
  subnet_id      = aws_subnet.cluster_private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

#######################################
# Routes
#######################################

resource "aws_route" "public_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.main_internet_gateway.id
}
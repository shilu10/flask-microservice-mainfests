terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">2.25.0"
    }
    kubectl = {
      source  = "registry.terraform.io/gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}



provider "aws" {
 
  region = "us-east-1"
}

# Standard Security group for the eks cluster
resource "aws_security_group" "eks_cluster" {
  name        = "eks cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = module.cluster_network.vpc_id

  tags = {
    Name = "flask-microservice-cluster-sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}


# Standard security group for eks nodes 
resource "aws_security_group" "eks_nodes" {
  name        = "microservice-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = module.cluster_network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                           = "microservice-node-sg"
    
  }
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}


module "cluster_network" {
  source = "./modules/cluster-network/"
  cluster_vpc_cidr_block = var.cluster_vpc_cidr_block
  cluster_azs            = var.cluster_azs
  cluster_public_subnets = var.cluster_public_subnets
  security_group_description = "This is for the cluster security group"
  cluster_private_subnets = var.cluster_private_subnets
  ingress = {
    description = "ssh rule"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = "0.0.0.0/0"
  }
  egress = {
    description = "full access to outside world"
    from_port = 0
    to_port = 0
    protocol = "ALL"
    cidr_blocks = "0.0.0.0/0"
  }
  cluster_security_group_name = var.cluster_security_group_name
}


module "eks_cluster" {
  source = "./modules/eks-cluster"
  vpc_id                = module.cluster_network.vpc_id
  cluster_name          = var.cluster_name
  cluster_iam_role_name = var.cluster_iam_role_name
  subnet_ids = module.cluster_network.cluster_public_subnets_ids[*]
  depends_on = [module.cluster_network]
  cluster_security_group_ids = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
}

data "aws_eks_cluster_auth" "cluster_auth"{
  name = var.cluster_name
  depends_on = [module.eks_cluster]
}

module "wokers" {
  source = "./modules/worker-nodes"
  cluster_workernodes_iam_role_name = var.cluster_workernodes_iam_role_name
  node_group_name = var.node_group_name
  subnet_ids = module.cluster_network.cluster_public_subnets_ids[*]
  instance_types = var.instance_types
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
  cluster_name = var.cluster_name
  depends_on = [module.eks_cluster]
}

module "argocd_module" {
  source = "./modules/argocd_"
  override_namespace = "argocd"
  cluster_host_details = module.eks_cluster.cluster_endpoints
  cluster_ca_certificate = module.eks_cluster.cluster_ca
 # cluster_token = data.aws_eks_cluster_auth.cluster_auth.token
}



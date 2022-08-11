subnet_ips = {
  "first" : "192.168.1.0/24"
  "second" : "192.168.2.0/24"
  "third" : "192.168.3.0/24"
}

cluster_name = "flask-microservice"

node_group_name = "new-cluster_worker_nodes"

cluster_iam_role_name = "new-cluster-iam-role"

cluster_workernodes_iam_role_name = "new-worker_node_iam_role"

max_size = 4

min_size = 0

desired_size = 0

cluster_vpc_cidr_block = "10.169.0.0/16"

cluster_azs = ["us-east-1a", "us-east-1b"]

cluster_public_subnets = ["10.169.1.0/24", "10.169.2.0/24"]

cluster_private_subnets = ["10.169.3.0/24"]

cluster_security_group_name = "cluster-security-group"

instance_types = ["t2.xlarge"]
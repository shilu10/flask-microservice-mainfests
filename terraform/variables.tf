variable "subnet_ips" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "node_group_name"{
  type = string
}

variable "cluster_iam_role_name"{
  type = string
}

variable "cluster_workernodes_iam_role_name"{
  type = string
}

variable "max_size"{
  type = number
}

variable "min_size"{
  type = number
}

variable "desired_size"{
  type = number
}

variable "cluster_vpc_cidr_block"{
  type = string
}

variable "cluster_azs"{
  type = list(string)
}

variable "cluster_public_subnets"{
  type = list(string)
}

variable "cluster_private_subnets"{
  type = list(string)
}

variable "cluster_security_group_name"{
  type = string
}

variable "instance_types"{
  type = list(string)
}
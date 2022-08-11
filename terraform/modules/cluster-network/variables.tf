variable "cluster_public_subnets" {
  type = list(string)
  description = "Need a subnets for the cluster, so it can place the workers on to it"
}

variable "cluster_vpc_cidr_block" {
  type        = string
  description = "This is the cluster vpc id"
}

variable "cluster_azs" {
  type = list(string)
}

variable "cluster_private_subnets" {
  type = list(string)
  nullable = true
  description = "Need a subnets for the cluster, so it can place the workers on to it"
}

variable "security_group_description" {
  type        = string
  description = "Securoty group description"
}

variable "ingress" {
  type        = map(string)
  description = "This is for the ingress configuration"
}

variable "egress" {
  type        = map(string)
  description = "This is for the egress configuration"
}

variable "cluster_security_group_name"{
    type = string
}
variable "cluster_iam_role_name" {
 type        = string
  default     = "cluster-iam-role"
  description = "This name will be used for the iam role which is created for the cluster"
}

variable "vpc_id" {
  type        = string
  description = "Provide a Vpc Id"
}

variable "cluster_name" {
  type        = string
  description = "Provide a cluster name"
}

variable "subnet_ids" {
  type = list
}

variable "cluster_security_group_ids" {
  type = list
}
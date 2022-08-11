variable "cluster_workernodes_iam_role_name" {
  type        = string
 
  description = "This is for the iam role of the worker nodes"
}

variable "node_group_name" {
  type        = string
 
  description = "This is for the name of the clusters node group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "This is for the subnet for the nodes"
}

variable "instance_types" {
  type        = list(string)
  description = "Size of the instances, by default it is t2.micro"
}

variable "desired_size" {
  type        = number
  description = "This is for the number of instances when there is traffic"
}

variable "min_size" {
  type        = number
  description = "This is for the number of instances when there is little or no traffic"
}

variable "max_size" {
  type        = number
  description = "This is for the number of instances when there is more traffic"
}

variable "cluster_name"{
  type = string
}
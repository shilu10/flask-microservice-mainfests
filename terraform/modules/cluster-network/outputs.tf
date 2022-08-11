output "cluster_public_subnets_ids" {
  value = aws_subnet.cluster_public_subnets[*].id
}

output "vpc_id" {
  value = aws_vpc.cluster_vpc.id
}

output "cluster_private_subnets_ids" {
  value = aws_subnet.cluster_private_subnets[*].id
}

output "cluster_security_group"{
  value = aws_security_group.cluster_security_group
}
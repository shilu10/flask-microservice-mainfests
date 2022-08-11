#output "cluster_iam" {
#  value = aws_iam_role.eks_iam_role
#}

output "cluster_name" {
  value = aws_eks_cluster.flask_microservice_cluster.name
}

output "cluster_endpoints" {
  value = aws_eks_cluster.flask_microservice_cluster.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.flask_microservice_cluster.certificate_authority[0].data
}


resource "aws_eks_cluster" "flask_microservice_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn
  

  vpc_config {
    subnet_ids = var.subnet_ids[*]
    security_group_ids = var.cluster_security_group_ids
    endpoint_private_access = true
    endpoint_public_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  depends_on = [
   # aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
   # aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_EKS,
    aws_iam_role.eks_iam_role,
  ]

}


resource "aws_iam_role" "eks_iam_role" {
  name = var.cluster_iam_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}





terraform {
  required_providers {
   
    kubectl = {
      source  = "registry.terraform.io/gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

data "aws_eks_cluster_auth" "cluster_auth"{
  name = "flask-microservice"
}

provider "kubectl" {
  host                   = var.cluster_host_details
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}


data "kubectl_file_documents" "namespace" {
  content = file("../argocd/namespace.yaml")
}

data "kubectl_file_documents" "argocd" {
  content = file("../argocd/install.yaml")
}

resource "kubectl_manifest" "namespace" {
  count              = length(data.kubectl_file_documents.namespace.documents)
  yaml_body          = element(data.kubectl_file_documents.namespace.documents, count.index)
  override_namespace = var.override_namespace
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.namespace,
  ]
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = var.override_namespace
}

data "kubectl_file_documents" "flask-microservice" {
  content = file("../argocd/flask-microservice-argocd-config.yaml")
}

resource "kubectl_manifest" "flask-microservice-app" {
  depends_on = [
    kubectl_manifest.argocd,
  ]
  count              = length(data.kubectl_file_documents.flask-microservice.documents)
  yaml_body          = element(data.kubectl_file_documents.flask-microservice.documents, count.index)
  override_namespace = var.override_namespace
}
output "cluster_endpoint" {
  description = "value of the cluster endpoint"
  value = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "value of the cluster name"
  value = aws_eks_cluster.main.name
}
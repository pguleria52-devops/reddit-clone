resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
    }]
 })

 tags = {
   Name = "${var.cluster_name}-eks-cluster-role"
 }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "main" {
  name = var.cluster_name
  version = var.cluster_version
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = var.subnet_id
  }
  depends_on = [ aws_iam_role_policy_attachment.cluster_policy ]
}

resource "aws_iam_role" "slave" {
  name = "${var.cluster_name}-eks-slave-role"
   assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
      }
    }]
  })
   
   tags = {
    Name = "${var.cluster_name}-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "slave_policy" {
   for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role = aws_iam_role.slave.name
}

resource "aws_eks_node_group" "slave_group" {
  for_each = var.node_group
  cluster_name = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn = aws_iam_role.slave.arn
  subnet_ids = var.subnet_id
  scaling_config {
    min_size = each.value.scaling_config.min_size
    max_size = each.value.scaling_config.max_size
    desired_size = each.value.scaling_config.desired_size
  }
  instance_types = each.value.instance_types
  capacity_type = each.value.capacity_type
  depends_on = [ aws_iam_role_policy_attachment.slave_policy ]
}
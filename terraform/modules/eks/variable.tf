variable "cluster_name" {
  description = "value of the cluster name"
  type = string
}

variable "cluster_version" {
  description = "value of the cluster version"
  type = string
}

variable "vpc_id" {
  description = "value of the VPC ID"
  type = string
}

variable "subnet_id" {
  description = "value of the subnet ID"
  type = list(string)
}

variable "node_group" {
  description = "Worker group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type = string
    scaling_config = object({
      desired_size = number
      max_size = number
      min_size = number 
    })
  }))
}
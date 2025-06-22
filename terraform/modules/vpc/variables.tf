variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  
}

variable "public_subnet" {
  description = "values for public subnet"
  type = list(string)
}

variable "private_subnet" {
  description = "values for private subnet"
  type = list(string)
}

variable "availability_zones" {
  description = "values for availability zones"
  type = list(string)
}
variable "cluster_name" {
  description = "values for cluster name"
  type = string
}
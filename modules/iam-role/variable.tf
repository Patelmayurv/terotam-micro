variable "cluster_name" {

  description = "Name of the EKS cluster"
  type        = string


}

variable "project_name" {

  description = "Name of the project"
  type        = string


}

variable "env" {

  description = "Environment (e.g., dev, staging, prod)"
  type        = string


}

# variable "kms_key_arn" {
#   type = string
# }


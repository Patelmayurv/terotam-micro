output "eks_cluster_role_arn" {

  description = "ARN of the IAM role for the EKS cluster"
  value       = aws_iam_role.eks_cluster_auto_role.arn

}


output "eks_node_group_role_arn" {

  description = "ARN of the IAM role used by the EKS node group"
  value       = aws_iam_role.eks_auto_node_group_role.arn

}

# output "karpenter-node-role_arn" {

#   description = "ARN of the IAM role used by Karpenter-managed nodes"
#   value       = aws_iam_role.karpenter-node-role.arn
# }

# output "karpenter-node-role_name" {

#   description = "Name of the IAM role used by Karpenter-managed nodes"
#   value       = aws_iam_role.karpenter-node-role.name
# }

output "eks_cluster_role_name" {

  description = "Name of the IAM role used by the EKS control plane"
  value       = aws_iam_role.eks_cluster_auto_role.name
}


output "eks_node_group_role_name" {

  description = "Name of the IAM role used by the EKS node group"
  value       = aws_iam_role.eks_auto_node_group_role.name
}

# output "eks_kms_policy_arn" {
#   description = "ARN of the KMS policy created for EKS"
#   value       = module.eks_cluster_role.kms_policy_arn
# }


##########  IAM Role for EKS Cluster ###############

resource "aws_iam_role" "eks_cluster_auto_role" {
  name = "${var.cluster_name}-${var.env}-eks-cluster-auto-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "sts:TagSession",
          "sts:AssumeRole"
        ]
      }
    ]
  })

  tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = "true"
  }
}

############# Attach IAM policy To Cluster Role ###########

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role       = aws_iam_role.eks_cluster_auto_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {

  role       = aws_iam_role.eks_cluster_auto_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
}


resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.eks_cluster_auto_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.eks_cluster_auto_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.eks_cluster_auto_role.name
}

# ############## Attach AmazonEKSVPCResourceController ###################33

# resource "aws_iam_role_policy_attachment" "eks_cluster_vpc_controller" {

#   role       = aws_iam_role.eks_cluster_auto_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
# }


#######################3 IAM Role for Node Group #####################



resource "aws_iam_role" "eks_auto_node_group_role" {

  name = "${var.cluster_name}-${var.env}-eks-auto-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })


  tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = "true"
  }
}




############### Attach AmazonEC2ContainerRegistryReadOnly ##################

resource "aws_iam_role_policy_attachment" "registry_read_only" {

  role       = aws_iam_role.eks_auto_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.eks_auto_node_group_role.name
}

################### Attach AmazonSSMFullAccess ##################

resource "aws_iam_role_policy_attachment" "ssm_full_access" {

  role       = aws_iam_role.eks_auto_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"

}

################# Attach AmazonSSMManagedInstanceCore ###############3

resource "aws_iam_role_policy_attachment" "s3_full_access" {

  role       = aws_iam_role.eks_auto_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}


########### Attach AmazonSSMManagedInstanceCore ###############

resource "aws_iam_role_policy_attachment" "ssm_core" {

  role       = aws_iam_role.eks_auto_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

# Attach AutoScalingFullAccess

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodeMinimalPolicy" {

  role       = aws_iam_role.eks_auto_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"

}



# ############## For addition access to karpenter ###############

# resource "aws_iam_policy" "eks_managed_node_group_policy" {
#   name        = "AmazonEKSManagedNodeGroupPolicy"
#   description = "IAM policy for AWS Load Balancer Controller"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "VisualEditor"
#         Effect = "Allow"
#         Action = [
#           "iam:CreateInstanceProfile",
#           "iam:TagInstanceProfile",
#           "iam:GetInstanceProfile",
#           "iam:AddRoleToInstanceProfile",
#           "pricing:GetProducts",
#           "iam:PassRole",
#           "ec2:*",
#           "eks:*"

#         ]
#         Resource = "*"
#       }
#     ]
#   })

#   tags = {
#     Name        = "AmazonEKSManagedNodeGroupPolicy"
#     Environment = var.env
#     terraform   = "true"
#   }
# }


# resource "aws_iam_role_policy_attachment" "eks_managed_node_group_policy" {
#   role       = aws_iam_role.eks_node_group_role.name # Ensure this is the correct IAM role name
#   policy_arn = aws_iam_policy.eks_managed_node_group_policy.arn
# }





# resource "aws_iam_role_policy_attachment" "eks_load_balancing" {
#   role       = aws_iam_role.eks_node_group_role.name # Ensure this is the correct IAM role name
#   policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
# }





# ######   Karpenter Node Role ##############


# resource "aws_iam_role" "karpenter-node-role" {
#   name = "KarpenterNodeRole-${var.cluster_name}"

#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "ec2.amazonaws.com"
#         },
#         "Action" : "sts:AssumeRole"
#       }
#     ]
#   })

#   tags = {
#     Environment = var.env
#     Project     = var.project_name
#     Terraform   = "true"
#   }
# }

# # Attach Policies to Custom Node Role
# resource "aws_iam_role_policy_attachment" "karpenter_worker_node_policy" {
#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_cni_policy" {
#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_ecr_readonly" {
#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_ecr_pullonly" {
#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
# }


# resource "aws_iam_role_policy_attachment" "karpenter_ssm" {
#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }


# resource "aws_iam_role_policy_attachment" "karpenter_ssm_full_access" {

#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"

# }

# resource "aws_iam_role_policy_attachment" "karpenter_s3_full_access" {

#   role       = aws_iam_role.karpenter-node-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

# }






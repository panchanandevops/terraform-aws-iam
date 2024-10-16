variable "env" {
  description = "Environment name."
  type        = string
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}

variable "iam_user_group_mapping" {
  description = "Mapping of IAM users to their respective groups for organizational structure."
  type = map(string)
  default = {
    developer = "developer_group"
    manager   = "eks_admin_group"
  }
}

variable "iam_group_k8s_group_mapping" {
  description = "Mapping of IAM groups to their associated EKS role configurations, including role actions, pass role permissions, and Kubernetes groups."
  type = map(object({
    role_name   = string
    role_actions = list(string)
    pass_role   = bool
    k8s_groups   = list(string)
  }))

  default = {
    eks_admin_group = {
      role_name   = "eks-admin"
      role_actions = ["eks:*"]
      pass_role   = true
      k8s_groups   = ["k8s-admin"]
    }

    developer_group = {
      role_name   = "developer-role"
      role_actions = ["eks:DescribeCluster", "eks:ListClusters"]
      pass_role   = false
      k8s_groups   = ["k8s-viewer"]
    }
  }
}


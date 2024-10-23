
# Terraform AWS IAM Module

This Terraform module sets up AWS IAM roles, policies, users, groups, and access configurations for EKS. The module is designed to create a structured IAM configuration with role-based access to an EKS cluster, ensuring permissions are properly assigned between IAM users, groups, and roles.

## Features

- Create IAM roles and attach policies for Kubernetes cluster management (EKS).
- Assign IAM roles to specific groups that map to Kubernetes RBAC.
- Attach necessary policies for `sts:AssumeRole` to EKS.
- Manage IAM users and groups, ensuring users belong to specific organizational groups.
- Output IAM role ARNs for easy reference and integration with other modules.



## Requirements

- Terraform `>= 1.0`
- AWS Provider `~> 5.49`

## Usage

To use this module, you need to define the IAM group-to-role mapping and IAM user-to-group mapping based on your organization's requirements.

### Example Configuration

```hcl
module "iam" {
  source = "./iam"

  env      = "prod"
  eks_name = "my-eks-cluster"
  account_id = "123456789012"

  iam_user_group_mapping = {
    developer = "developer_group"
    manager   = "eks_admin_group"
  }

  iam_group_k8s_group_mapping = {
    eks_admin_group = {
      role_name   = "eks-admin"
      role_actions = ["eks:*"]
      pass_role   = true
      k8s_groups   = ["my-admin"]
    }

    developer_group = {
      role_name   = "developer-role"
      role_actions = ["eks:DescribeCluster", "eks:ListClusters"]
      pass_role   = false
      k8s_groups   = ["my-viewer"]
    }
  }
}
```

### Inputs

| Variable                        | Description                                                   | Type          | Default                                      |
|----------------------------------|---------------------------------------------------------------|---------------|----------------------------------------------|
| `env`                            | Environment name (e.g., dev, staging, prod).                   | `string`      | N/A                                          |
| `eks_name`                       | Name of the EKS cluster.                                       | `string`      | N/A                                          |
| `account_id`                     | AWS account ID for the IAM role assumption.                    | `string`      | N/A                                          |
| `iam_user_group_mapping`         | Mapping of IAM users to their respective groups.               | `map(string)` | `{ developer = "developer_group", manager = "eks_admin_group" }` |
| `iam_group_k8s_group_mapping`    | Mapping of IAM groups to their associated roles and policies.  | `map(object)` | Defined with admin and developer group defaults. |

### Outputs

| Output           | Description                                |
|------------------|--------------------------------------------|
| `iam_role_arns`  | Mapping of IAM groups to their role ARNs.  |

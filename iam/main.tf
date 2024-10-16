data "aws_caller_identity" "current" {}

resource "aws_iam_role" "roles" {
  for_each = var.iam_group_k8s_group_mapping

  name = "${var.env}-${var.eks_name}-${each.value.role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "policies" {
  for_each = var.iam_group_k8s_group_mapping

  name = "${var.env}-${var.eks_name}-${each.key}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = flatten([
      [
        {
          Effect   = "Allow"
          Action   = each.value.role_actions
          Resource = "*"
        }
      ],
      each.value.pass_role ? [{
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      }] : []
    ])
  })
}


resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.iam_group_k8s_group_mapping

  role       = aws_iam_role.roles[each.key].name
  policy_arn = aws_iam_policy.policies[each.key].arn
}

resource "aws_iam_user" "users" {
  for_each = var.iam_user_group_mapping

  name = each.key
}

resource "aws_iam_group" "groups" {
  for_each = toset(values(var.iam_user_group_mapping))

  name = each.value
}

resource "aws_iam_user_group_membership" "group_memberships" {
  for_each = var.iam_user_group_mapping

  user   = aws_iam_user.users[each.key].name
  groups = [aws_iam_group.groups[each.value].name]
}

resource "aws_iam_policy" "assume_policies" {
  for_each = var.iam_group_k8s_group_mapping

  name = "amazon-EKS-assume-${each.key}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Resource = aws_iam_role.roles[each.key].arn
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "groups_role_attachment" {
  for_each = var.iam_group_k8s_group_mapping

  group      = aws_iam_group.groups[each.key].name
  policy_arn = aws_iam_policy.assume_policies[each.key].arn
}

resource "aws_eks_access_entry" "eks_access" {
  for_each = var.iam_group_k8s_group_mapping

  cluster_name      = var.eks_name
  principal_arn     = aws_iam_role.roles[each.key].arn
  kubernetes_groups = each.value.k8s_groups
}

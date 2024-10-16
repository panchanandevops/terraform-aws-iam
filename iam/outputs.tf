output "iam_role_arns" {
  description = "Mapping of IAM groups to their corresponding role ARNs."
  value = { for group_key, role in aws_iam_role.roles : group_key => role.arn }
}

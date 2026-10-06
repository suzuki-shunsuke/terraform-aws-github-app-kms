output "policy_arn" {
  value       = aws_iam_policy.sign.arn
  description = "AWS IAM Policy ARN to sign"
}

output "role_arn" {
  value       = one(aws_iam_role.main[*].arn)
  description = "AWS IAM Role ARN to sign. null if create_role is false"
}

output "key_arn" {
  value       = aws_kms_external_key.main.arn
  description = "AWS KMS Key ARN to sign"
}

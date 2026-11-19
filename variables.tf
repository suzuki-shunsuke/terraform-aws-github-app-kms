variable "app_slug" {
  type        = string
  description = "GitHub App slug"
}

variable "imported" {
  type        = bool
  description = "Whether the private key is imported"
}

variable "create_role" {
  type        = bool
  description = "Whether the IAM Role is created"
  default     = true
}

variable "conditions" {
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  description = "conditions to assume the IAM Role"
  default     = []
}

variable "signer_arns" {
  type        = list(string)
  description = <<-EOT
  IAM principal ARNs allowed to sign with the KMS key in addition to the IAM Role created by this module.
  The key policy denies kms:Sign to any other principal.
  Specify IAM Role ARNs, not assumed role session ARNs.
  If create_role is false, this must not be empty.
  Principals in the same account also need kms:Sign by an IAM policy (e.g. attach policy_arn).
  EOT
  default     = []
}

##

variable "key_description" {
  type        = string
  description = "The KMS key description. Defaults to \"<app_slug> GitHub App JWT signing key\""
  default     = null
}

variable "key_alias" {
  type        = string
  description = "The KMS key alias. Defaults to \"alias/github-app-<app_slug>\""
  default     = null
}

variable "role_name" {
  type        = string
  description = "The IAM Role name. Defaults to \"sign-<app_slug>\""
  default     = null
}

variable "role_description" {
  type        = string
  description = "The IAM Role description. Defaults to \"Sign <app_slug> GitHub App JWTs with AWS KMS\""
  default     = null
}

variable "policy_name" {
  type        = string
  description = "The IAM Policy name. Defaults to \"sign-<app_slug>\""
  default     = null
}

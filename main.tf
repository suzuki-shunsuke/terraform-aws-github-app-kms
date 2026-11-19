locals {
  key_description  = coalesce(var.key_description, "${var.app_slug} GitHub App JWT signing key")
  key_alias        = coalesce(var.key_alias, "alias/github-app-${var.app_slug}")
  role_name        = coalesce(var.role_name, "sign-${var.app_slug}")
  role_description = coalesce(var.role_description, "Sign ${var.app_slug} GitHub App JWTs with AWS KMS")
  policy_name      = coalesce(var.policy_name, "sign-${var.app_slug}")
  # Principals allowed to sign with the key. The key policy denies kms:Sign to everyone else.
  signer_arns = concat(aws_iam_role.main[*].arn, var.signer_arns)
}

resource "aws_kms_external_key" "main" {
  description  = local.key_description
  key_spec     = "RSA_2048"
  key_usage    = "SIGN_VERIFY"
  multi_region = false
  enabled      = var.imported
  policy       = data.aws_iam_policy_document.key.json

  lifecycle {
    precondition {
      condition     = length(local.signer_arns) > 0
      error_message = "signer_arns must not be empty when create_role is false."
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "key" {
  # The default key policy. It delegates access to the key to IAM policies in the account.
  # Removing it would make the key unmanageable.
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Because of the statement above, any IAM principal in the account could sign with the key
  # (and issue GitHub App installation access tokens at any time) only by being granted kms:Sign by an IAM policy.
  # Restrict signing to the given principals.
  statement {
    sid       = "DenySignExceptAllowedPrincipals"
    effect    = "Deny"
    actions   = ["kms:Sign"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = local.signer_arns
    }
  }
}

resource "aws_kms_alias" "main" {
  name          = local.key_alias
  target_key_id = aws_kms_external_key.main.id
}

resource "aws_iam_role" "main" {
  count              = var.create_role ? 1 : 0
  name               = local.role_name
  description        = local.role_description
  assume_role_policy = data.aws_iam_policy_document.sign_assume_role[0].json
}

data "aws_iam_policy_document" "sign_assume_role" {
  count = var.create_role ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = var.conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_role ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role_policy_attachment" "sign" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.main[0].id
  policy_arn = aws_iam_policy.sign.arn
}

resource "aws_iam_policy" "sign" {
  name   = local.policy_name
  policy = data.aws_iam_policy_document.sign.json
}

data "aws_iam_policy_document" "sign" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Sign"]
    resources = [aws_kms_external_key.main.arn]

    condition {
      test     = "StringEquals"
      variable = "kms:SigningAlgorithm"
      values   = ["RSASSA_PKCS1_V1_5_SHA_256"]
    }
  }
}

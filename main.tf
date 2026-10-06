locals {
  key_description  = coalesce(var.key_description, "${var.app_slug} GitHub App JWT signing key")
  key_alias        = coalesce(var.key_alias, "alias/github-app-${var.app_slug}")
  role_name        = coalesce(var.role_name, "sign-${var.app_slug}")
  role_description = coalesce(var.role_description, "Sign ${var.app_slug} GitHub App JWTs with AWS KMS")
  policy_name      = coalesce(var.policy_name, "sign-${var.app_slug}")
}

resource "aws_kms_external_key" "main" {
  description  = local.key_description
  key_spec     = "RSA_2048"
  key_usage    = "SIGN_VERIFY"
  multi_region = false
  enabled      = var.imported
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

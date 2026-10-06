# terraform-aws-github-app-kms

Terraform Module to manage a GitHub App private key with AWS KMS.

ref. https://github.com/suzuki-shunsuke/agent-skills/blob/main/skills/github-app-private-key-aws-kms/SKILL.md

## Example

```tf
module "foo" {
  source   = "github.com/suzuki-shunsuke/terraform-aws-github-app-kms"
  app_slug = "suzuki-shunsuke-app"
  imported = false
  conditions = [
    {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:suzuki-shunsuke/*:*", "repo:suzuki-shunsuke@13323303/*:*"]
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.63 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.sign](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sign](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_external_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_external_key) | resource |
| [aws_iam_openid_connect_provider.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.sign](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sign_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_slug"></a> [app\_slug](#input\_app\_slug) | GitHub App slug | `string` | n/a | yes |
| <a name="input_conditions"></a> [conditions](#input\_conditions) | conditions to assume the IAM Role | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether the IAM Role is created | `bool` | `true` | no |
| <a name="input_imported"></a> [imported](#input\_imported) | Whether the private key is imported | `bool` | n/a | yes |
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | The KMS key alias. Defaults to "alias/github-app-<app\_slug>" | `string` | `null` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | The KMS key description. Defaults to "<app\_slug> GitHub App JWT signing key" | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | The IAM Policy name. Defaults to "sign-<app\_slug>" | `string` | `null` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | The IAM Role description. Defaults to "Sign <app\_slug> GitHub App JWTs with AWS KMS" | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The IAM Role name. Defaults to "sign-<app\_slug>" | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | AWS KMS Key ARN to sign |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | AWS IAM Policy ARN to sign |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | AWS IAM Role ARN to sign. null if create\_role is false |
<!-- END_TF_DOCS -->

# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform Config Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-config/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-config.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-config.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-config/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
Wrapper for organization-wide AWS Config: configuration recorders in every member account through a
service-managed CloudFormation StackSet with auto-deployment, a direct recorder in the management account,
a central SSE-KMS delivery bucket in the log archive account, an organization aggregator in the delegated
administrator account, and optional organization managed rules and conformance packs.


### ✨ Features

- 🛰️ [Organization-wide recorders via StackSet](#organization-wide-recorders-via-stackset) - Service-managed StackSet deploys a recorder, delivery channel, and IAM role to every member account, including new ones.

- 🏛️ [Management account recorder](#management-account-recorder) - Direct Terraform recorder in the management account, which StackSets never target.

- 🔐 [Central delivery bucket with CMK](#central-delivery-bucket-with-cmk) - Log archive bucket encrypted with a customer-managed KMS key, scoped to the organization.

- 📊 [Organization aggregator, rules, and conformance packs](#organization-aggregator,-rules,-and-conformance-packs) - Aggregator plus organization managed rules and conformance packs from the delegated administrator account.




## 🚀 Quick Start
```hcl
config_parameters = {
  enable = true

  # -------------------------------------------------------------------------
  # Top-level — only add keys when you need non-defaults (see ../../locals.tf)
  # -------------------------------------------------------------------------
  # s3_key_prefix = "config"
  # tags          = {}

  regions = ["us-east-2", "us-east-1"] # Default: [<aws.org provider Region>] — the provider Region is the home Region and must be listed

  # -------------------------------------------------------------------------
  # recorder — shared by the StackSet (members) and the management account.
  # -------------------------------------------------------------------------
  recorder = {
    # name                          = null  # default: "${metadata.common_name}-config-recorder"
    # role_name                     = null  # default: "${metadata.common_name}-config-recorder" (members append "-<region>")
    # include_global_resource_types = true
    # recording_frequency           = "CONTINUOUS"
    # delivery_frequency            = "TwentyFour_Hours"

    recording_frequency = "DAILY" # Default: "CONTINUOUS"
  }

  # -------------------------------------------------------------------------
  # stackset — member accounts (SERVICE_MANAGED, auto-deployment).
  # -------------------------------------------------------------------------
  stackset = {
    # enable                           = true
    # name                             = null  # default: "${metadata.common_name}-config-recorder"
    # organizational_unit_ids          = null  # default: [organization root id]
    # max_concurrent_percentage        = 100
    # failure_tolerance_percentage     = 10
    # retain_stacks_on_account_removal = false
  }

  # -------------------------------------------------------------------------
  # management_account — direct recorder (StackSets skip the management account).
  # -------------------------------------------------------------------------
  management_account = {
    # enable = true
  }

  # -------------------------------------------------------------------------
  # aggregator — organization aggregator in the delegated admin account.
  # -------------------------------------------------------------------------
  aggregator = {
    # enable = true
    # name   = null  # default: "${metadata.common_name}-org-aggregator"
  }

  # -------------------------------------------------------------------------
  # log_bucket — commented lines show wrapper defaults; uncomment to override.
  # -------------------------------------------------------------------------
  log_bucket = {
    # bucket_name                       = null  # default: "${metadata.common_name}-config-logs-<log_account_id>"
    # enable_versioning                 = true
    # lifecycle_glacier_transition_days = null
    # lifecycle_expiration_days         = null

    force_destroy = true # Default: false
  }

  # -------------------------------------------------------------------------
  # kms — commented lines show wrapper defaults; uncomment to override.
  # -------------------------------------------------------------------------
  kms = {
    # enable                  = true
    # alias_name              = null  # default: "alias/${metadata.common_name}-config"
    # description             = null
    # deletion_window_in_days = 30
    # enable_key_rotation     = true

    deletion_window_in_days = 7 # Default: 30
  }
}
```


## 🔧 Additional Features Usage

### Organization-wide recorders via StackSet
Creates `aws_cloudformation_stack_set` (SERVICE_MANAGED, auto-deployment) and `aws_cloudformation_stack_instances` on `aws.org`,
targeting the organization root by default. Each stack creates `AWS::Config::ConfigurationRecorder`, `AWS::Config::DeliveryChannel`,
and a per-Region IAM role delivering to the central bucket. Narrow the scope with `stackset.organizational_unit_ids`.


<details><summary>Target specific OUs</summary>

```hcl
config_parameters = {
  enable = true

  stackset = {
    organizational_unit_ids = ["ou-xxxx-11111111", "ou-xxxx-22222222"] # Default: [organization root id]
  }
}
```


</details>


### Management account recorder
Creates `aws_config_configuration_recorder`, `aws_config_delivery_channel`, and `aws_config_configuration_recorder_status` on `aws.org`
in every Region of `regions` (one global IAM role), using the same recorder settings as member accounts. Disable with `management_account.enable = false` if the account already records.


<details><summary>Skip the management account recorder</summary>

```hcl
config_parameters = {
  enable = true

  management_account = {
    enable = false # Default: true
  }
}
```


</details>


### Central delivery bucket with CMK
Creates the bucket on `aws.log` and the CMK on `aws.kms`. Bucket and key policies allow `config.amazonaws.com` (`aws:SourceOrgID`)
and organization recorder roles (`aws:PrincipalOrgID`). Set `kms.enable = false` to fall back to SSE-S3.


<details><summary>Lifecycle and SSE-S3</summary>

```hcl
config_parameters = {
  enable = true

  log_bucket = {
    lifecycle_glacier_transition_days = 90  # Default: null
    lifecycle_expiration_days         = 730 # Default: null
  }

  kms = {
    enable = false # Default: true
  }
}
```


</details>


### Organization aggregator, rules, and conformance packs
On `aws.sec`, creates `aws_config_configuration_aggregator` (the Regions in `regions`) with an `AWSConfigRoleForOrganizations` role,
`aws_config_organization_managed_rule` per `organization_managed_rules` entry, and `aws_config_organization_conformance_pack`
per `organization_conformance_packs` entry. Rules and packs are created after the recorders.


<details><summary>Organization managed rules</summary>

```hcl
config_parameters = {
  enable = true

  organization_managed_rules = {
    "s3-bucket-public-read-prohibited" = {
      rule_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
    "access-keys-rotated" = {
      rule_identifier  = "ACCESS_KEYS_ROTATED"
      input_parameters = { maxAccessKeyAge = "90" }
    }
  }
}
```


</details>

<details><summary>Organization conformance pack</summary>

```hcl
config_parameters = {
  enable = true

  organization_conformance_packs = {
    "operational-best-practices-for-s3" = {
      template_body = file("conformance-packs/s3.yaml")
    }
  }
}
```


</details>




## 📑 Inputs
| Name                                         | Description                                                                                                                                                                                        | Type           | Default                                                            | Required |
| -------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------ | -------- |
| enable                                       | When `true`, create bucket, KMS, StackSet, management recorder, and organization resources (`count` gate).                                                                                         | `bool`         | `false`                                                            | no       |
| regions                                      | Regions where recorders are deployed (members and management account); must include the `aws.org` provider Region (home).                                                                          | `list(string)` | `[<aws.org provider Region>]`                                      | no       |
| s3_key_prefix                                | Key prefix for delivered objects in the central bucket.                                                                                                                                            | `string`       | `"config"`                                                         | no       |
| recorder.name                                | Name of the configuration recorder and delivery channel (members and management).                                                                                                                  | `string`       | `` `{common_name}-config-recorder` ``                              | no       |
| recorder.role_name                           | Recorder IAM role name; member accounts append `-<region>`, the management account uses one global role.                                                                                           | `string`       | `` `{common_name}-config-recorder` ``                              | no       |
| recorder.include_global_resource_types       | Record global resource types (IAM), only in the home Region.                                                                                                                                       | `bool`         | `true`                                                             | no       |
| recorder.recording_frequency                 | `CONTINUOUS` or `DAILY`.                                                                                                                                                                           | `string`       | `"CONTINUOUS"`                                                     | no       |
| recorder.delivery_frequency                  | Configuration snapshot delivery frequency.                                                                                                                                                         | `string`       | `"TwentyFour_Hours"`                                               | no       |
| stackset.enable                              | Deploy recorders to member accounts through the StackSet.                                                                                                                                          | `bool`         | `true`                                                             | no       |
| stackset.name                                | `name` on `aws_cloudformation_stack_set`.                                                                                                                                                          | `string`       | `` `{common_name}-config-recorder` ``                              | no       |
| stackset.organizational_unit_ids             | Root or OU IDs targeted by the StackSet.                                                                                                                                                           | `list(string)` | `[root id]`                                                        | no       |
| stackset.max_concurrent_percentage           | Maximum percentage of accounts deployed concurrently.                                                                                                                                              | `number`       | `100`                                                              | no       |
| stackset.failure_tolerance_percentage        | Percentage of failed accounts tolerated before stopping.                                                                                                                                           | `number`       | `10`                                                               | no       |
| stackset.retain_stacks_on_account_removal    | Keep stacks in accounts removed from the targeted OUs.                                                                                                                                             | `bool`         | `false`                                                            | no       |
| management_account.enable                    | Create the recorder directly in the management account.                                                                                                                                            | `bool`         | `true`                                                             | no       |
| aggregator.enable                            | Create the organization aggregator in the delegated admin account.                                                                                                                                 | `bool`         | `true`                                                             | no       |
| aggregator.name                              | `name` on `aws_config_configuration_aggregator`.                                                                                                                                                   | `string`       | `` `{common_name}-org-aggregator` ``                               | no       |
| log_bucket.bucket_name                       | Globally unique `bucket` name on `aws_s3_bucket`.                                                                                                                                                  | `string`       | `` `{common_name}-config-logs-{log_account_id}` ``                 | no       |
| log_bucket.force_destroy                     | `force_destroy` on `aws_s3_bucket`.                                                                                                                                                                | `bool`         | `false`                                                            | no       |
| log_bucket.enable_versioning                 | S3 bucket versioning.                                                                                                                                                                              | `bool`         | `true`                                                             | no       |
| log_bucket.lifecycle_glacier_transition_days | Transition objects to `GLACIER` after N days; `null` skips.                                                                                                                                        | `number`       | `null`                                                             | no       |
| log_bucket.lifecycle_expiration_days         | Expire objects after N days; `null` skips.                                                                                                                                                         | `number`       | `null`                                                             | no       |
| kms.enable                                   | Create the CMK and use SSE-KMS for delivery; `false` uses SSE-S3.                                                                                                                                  | `bool`         | `true`                                                             | no       |
| kms.description                              | `description` on `aws_kms_key`.                                                                                                                                                                    | `string`       | `` `KMS key for AWS Config delivery encryption ({common_name})` `` | no       |
| kms.deletion_window_in_days                  | `deletion_window_in_days` on `aws_kms_key` (7–30).                                                                                                                                                 | `number`       | `30`                                                               | no       |
| kms.enable_key_rotation                      | `enable_key_rotation` on `aws_kms_key`.                                                                                                                                                            | `bool`         | `true`                                                             | no       |
| kms.alias_name                               | `name` on `aws_kms_alias`.                                                                                                                                                                         | `string`       | `` `alias/{common_name}-config` ``                                 | no       |
| organization_managed_rules                   | Map of rule name to `{ rule_identifier, description, input_parameters, maximum_execution_frequency, resource_types_scope, resource_id_scope, tag_key_scope, tag_value_scope, excluded_accounts }`. | `map(any)`     | `{}`                                                               | no       |
| tags                                         | A map of tags to assign to resources.                                                                                                                                                              | `map`          | `{}`                                                               | no       |







## ⚠️ Important Notes
- ⚠️ **Delegated administrator:** `aws.sec` must be registered as delegated administrator for `config.amazonaws.com` (aggregator) and `config-multiaccountsetup.amazonaws.com` (organization rules and conformance packs). Register both with `terraform-aws-wrapper-service-delegation` (`config = "<sec account id>"`, which also needs the trusted access principal `config-multiaccountsetup.amazonaws.com`), or set `aggregator.enable = false` and leave rules/packs empty.
- ⚠️ **StackSets trusted access:** `member.org.stacksets.cloudformation.amazonaws.com` must be enabled in AWS Organizations, and `aws.org` must be the management account (`call_as = SELF`).
- ℹ️ **Management account:** Service-managed StackSets never deploy to the management account; the module records it directly (`management_account.enable`).
- ⚠️ **One recorder per account and Region:** Accounts that already have a customer-managed recorder (for example Control Tower) fail the stack instance. Exclude their OUs via `stackset.organizational_unit_ids`. Security Hub v2 service-linked recorders do not conflict.
- 🌍 **Multi-Region:** `regions` deploys recorders (members via StackSet, management account directly) in every listed Region using the provider `region` argument; all of them deliver to the single central bucket and KMS key. The `aws.org` provider Region is the home Region and must be in the list.
- ℹ️ **Global resources:** IAM and other global resource types are recorded only in the home Region (when `recorder.include_global_resource_types = true`) to avoid duplicate configuration items and cost.
- ℹ️ **Organization rules / conformance packs:** Regional; this module creates them in the home Region only. Security Hub CSPM controls cover the other Regions, and they require these recorders in every linked Region.
- 💰 **Cost:** AWS Config bills per configuration item per account and Region — each added Region multiplies cost. `CONTINUOUS` records every change; `DAILY` reduces configuration item volume for high-churn accounts.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 
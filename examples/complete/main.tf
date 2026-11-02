module "wrapper_config" {
  source = "../../"

  providers = {
    aws.org = aws.org # Organization Management Account
    aws.sec = aws.sec # Security Tooling Account ( if exists )
    aws.log = aws.log # Security Logging Account ( if exists )
    aws.kms = aws.kms # Security KMS Account ( if exists )
  }

  metadata = local.metadata

  config_parameters = {
    enable = true

    # -------------------------------------------------------------------------
    # Top-level — only add keys when you need non-defaults (see ../../locals.tf)
    # -------------------------------------------------------------------------
    # s3_key_prefix = "config"
    # tags          = {}

    # regions = ["us-east-2", "us-east-1"] # Default: [<aws.org provider Region>] — the provider Region is the home Region and must be listed

    # -------------------------------------------------------------------------
    # recorder — shared by the StackSet (members) and the management account.
    # -------------------------------------------------------------------------
    recorder = {
      # name                          = null  # default: "${metadata.common_name}-config-recorder"
      # role_name                     = null  # default: "${metadata.common_name}-config-recorder" (members append "-<region>")
      # include_global_resource_types = true
      # recording_frequency           = "CONTINUOUS"
      # delivery_frequency            = "TwentyFour_Hours"

      # DAILY lowers cost for labs only — production must stay CONTINUOUS so security changes are recorded as they happen.
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
      enable = false # Default: true — requires the Config delegated administrator (service-delegation `config`)
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

    # -------------------------------------------------------------------------
    # organization_managed_rules — map keyed by rule name (default: {}).
    # -------------------------------------------------------------------------
    organization_managed_rules = {
      # "s3-bucket-public-read-prohibited" = {
      #   rule_identifier             = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
      #   description                 = null
      #   input_parameters            = null  # map, encoded as JSON
      #   maximum_execution_frequency = null
      #   resource_types_scope        = null
      #   excluded_accounts           = null
      #   tag_key_scope               = null
      #   tag_value_scope             = null
      # }
    }

    # -------------------------------------------------------------------------
    # organization_conformance_packs — map keyed by pack name (default: {}).
    # -------------------------------------------------------------------------
    organization_conformance_packs = {
      # "operational-best-practices-for-s3" = {
      #   template_body     = file("conformance-packs/s3.yaml")  # or template_s3_uri
      #   input_parameters  = {}
      #   excluded_accounts = null
      # }
    }
  }

  config_defaults = {}
}

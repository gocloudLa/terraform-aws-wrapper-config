resource "aws_cloudformation_stack_set" "this" {
  name        = var.stackset_name
  description = "AWS Config recorder and delivery channel for organization member accounts."

  permission_model = "SERVICE_MANAGED"
  call_as          = "SELF"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  template_body = file("${path.module}/templates/config-recorder.yaml")

  parameters = {
    HomeRegion                 = var.home_region
    RecorderName               = var.recorder_name
    RoleName                   = var.role_name
    BucketName                 = var.s3_bucket_name
    KeyPrefix                  = var.s3_key_prefix
    KmsKeyArn                  = var.kms_key_arn
    IncludeGlobalResourceTypes = tostring(var.include_global_resource_types)
    RecordingFrequency         = var.recording_frequency
    DeliveryFrequency          = var.delivery_frequency
  }

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = var.retain_stacks_on_account_removal
  }

  managed_execution {
    active = true
  }

  tags = var.tags

  lifecycle {
    # SERVICE_MANAGED stack sets report an administration role that is not configurable.
    ignore_changes = [administration_role_arn]
  }
}

resource "aws_cloudformation_stack_instances" "this" {
  stack_set_name = aws_cloudformation_stack_set.this.name
  call_as        = "SELF"

  # One operation for every Region; IAM role names carry the Region suffix so PARALLEL is safe.
  regions = var.regions

  deployment_targets {
    organizational_unit_ids = var.organizational_unit_ids
  }

  operation_preferences {
    max_concurrent_percentage    = var.max_concurrent_percentage
    failure_tolerance_percentage = var.failure_tolerance_percentage
    region_concurrency_type      = "PARALLEL"
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  lifecycle {
    precondition {
      condition     = length(var.organizational_unit_ids) > 0
      error_message = "organizational_unit_ids must contain at least one OU or root ID."
    }
    precondition {
      condition     = contains(var.regions, var.home_region)
      error_message = "regions must include the home Region (aws.org provider Region)."
    }
  }
}

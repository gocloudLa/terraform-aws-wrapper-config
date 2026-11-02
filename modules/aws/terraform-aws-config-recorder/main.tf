data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "delivery" {
  statement {
    sid    = "BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"]
  }

  statement {
    sid       = "BucketDelivery"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/${local.prefix_with_slash}AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn != "" ? [var.kms_key_arn] : []
    content {
      sid    = "KmsDelivery"
      effect = "Allow"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Decrypt",
        "kms:DescribeKey",
      ]
      resources = [statement.value]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "delivery" {
  name   = "config-delivery"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.delivery.json
}

# Key: AWS Region
resource "aws_config_configuration_recorder" "this" {
  for_each = toset(var.regions)

  region   = each.value
  name     = var.recorder_name
  role_arn = aws_iam_role.this.arn

  recording_group {
    all_supported = true
    # Global resource types (IAM) only in the home Region to avoid duplicate items and cost.
    include_global_resource_types = var.include_global_resource_types && each.value == var.home_region
  }

  recording_mode {
    recording_frequency = var.recording_frequency
  }

  lifecycle {
    precondition {
      condition     = contains(var.regions, var.home_region)
      error_message = "regions must include the home Region (aws.org provider Region)."
    }
  }
}

# Key: AWS Region
resource "aws_config_delivery_channel" "this" {
  for_each = aws_config_configuration_recorder.this

  region         = each.key
  name           = var.recorder_name
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = trim(var.s3_key_prefix, "/") != "" ? trim(var.s3_key_prefix, "/") : null
  s3_kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

  depends_on = [
    aws_config_configuration_recorder.this,
    aws_iam_role_policy.delivery,
  ]
}

# Key: AWS Region
resource "aws_config_configuration_recorder_status" "this" {
  for_each = aws_config_delivery_channel.this

  region     = each.key
  name       = aws_config_configuration_recorder.this[each.key].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

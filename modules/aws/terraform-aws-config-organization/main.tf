data "aws_partition" "current" {}

data "aws_iam_policy_document" "aggregator_assume" {
  count = var.enable_aggregator ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aggregator" {
  count = var.enable_aggregator ? 1 : 0

  name               = substr("${var.aggregator_name}-role", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.aggregator_assume[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "aggregator" {
  count = var.enable_aggregator ? 1 : 0

  role       = aws_iam_role.aggregator[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "organization" {
  count = var.enable_aggregator ? 1 : 0

  name = var.aggregator_name

  # Same Regions as the recorders: other Regions have no recorder and nothing to aggregate.
  organization_aggregation_source {
    regions  = var.aggregator_regions
    role_arn = aws_iam_role.aggregator[0].arn
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.aggregator]
}

# Key: rule name (map key of organization_managed_rules).
# input_parameters accepts a map (JSON-encoded here) or a pre-encoded JSON string.
resource "aws_config_organization_managed_rule" "this" {
  for_each = var.organization_managed_rules

  name                        = each.key
  rule_identifier             = each.value.rule_identifier
  description                 = try(each.value.description, null)
  input_parameters            = try(each.value.input_parameters, null) == null ? null : (can(tostring(each.value.input_parameters)) ? each.value.input_parameters : jsonencode(each.value.input_parameters))
  maximum_execution_frequency = try(each.value.maximum_execution_frequency, null)
  resource_types_scope        = try(each.value.resource_types_scope, null)
  resource_id_scope           = try(each.value.resource_id_scope, null)
  tag_key_scope               = try(each.value.tag_key_scope, null)
  tag_value_scope             = try(each.value.tag_value_scope, null)
  excluded_accounts           = try(each.value.excluded_accounts, null)
}

# Key: conformance pack name (map key of organization_conformance_packs).
resource "aws_config_organization_conformance_pack" "this" {
  for_each = var.organization_conformance_packs

  name              = each.key
  template_body     = try(each.value.template_body, null)
  template_s3_uri   = try(each.value.template_s3_uri, null)
  excluded_accounts = try(each.value.excluded_accounts, null)

  dynamic "input_parameter" {
    for_each = try(each.value.input_parameters, {})
    content {
      parameter_name  = input_parameter.key
      parameter_value = input_parameter.value
    }
  }

  lifecycle {
    precondition {
      condition     = (try(each.value.template_body, null) != null) != (try(each.value.template_s3_uri, null) != null)
      error_message = "Each organization conformance pack must set exactly one of template_body or template_s3_uri."
    }
  }
}

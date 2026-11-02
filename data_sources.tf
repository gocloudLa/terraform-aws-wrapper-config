data "aws_caller_identity" "log" {
  provider = aws.log
}

data "aws_region" "log" {
  provider = aws.log
}

data "aws_region" "org" {
  provider = aws.org
}

data "aws_organizations_organization" "this" {
  count    = local.config_enable
  provider = aws.org
}

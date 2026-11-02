locals {
  # One global IAM role shared by the recorders of every Region (IAM name max 64).
  role_name = substr(var.role_name, 0, 64)

  prefix_with_slash = (
    length(trim(var.s3_key_prefix, "/")) > 0 ?
    "${trim(var.s3_key_prefix, "/")}/" :
    ""
  )
}

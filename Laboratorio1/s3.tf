module "s3_bucket" {
  source = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git"
  bucket = "tfstate-s3-bucket"

    versioning = {
        enabled = true
    }

  lifecycle_rules = [
    {
      id      = "delete-old-versions"
      enabled = true
      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
}
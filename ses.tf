// Variables
variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

variable "access_key" {
  type        = string
  description = "The aws development account access key"
}

variable "secret_key" {
  type        = string
  description = "The aws development account secret key"
}

// Providers
provider "aws" {
  version    = "~> 2.57"
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

// Resources
resource "aws_ses_domain_identity" "domain" {
  domain = "{{EMAIL_DOMAIN}}"
}

resource "aws_ses_domain_dkim" "domain_dkim" {
  domain = "${aws_ses_domain_identity.domain.domain}"
}

resource "aws_s3_bucket" "emails_bucket" {
  bucket = "{{UNIQUE_BUCKET_NAME}}"
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  triggers = {
    "after" = aws_s3_bucket.emails_bucket.id
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.emails_bucket.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSESPuts",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::gabriel.araujo-emails/*"
        }
    ]
}
POLICY
  depends_on = [
    null_resource.delay
  ]
}

resource "aws_ses_receipt_rule" "store" {
  name          = "store"
  rule_set_name = "default-rule-set"
  enabled       = true
  scan_enabled  = true

  add_header_action {
    header_name  = "Custom-Header"
    header_value = "Added by SES"
    position     = 1
  }

  s3_action {
    bucket_name = "${aws_s3_bucket.emails_bucket.id}"
    object_key_prefix = "incoming"
    position    = 2
  }

  depends_on = [
    aws_s3_bucket_policy.bucket_policy,
    aws_ses_receipt_rule.store
  ]
}

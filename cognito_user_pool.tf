// Variables
variable "aws_region" {
  type = string
  description = "The region in which the resources will be created"
  default = "us-east-1"
}

variable "access_key" {
  type = string
  description = "The aws development account access key"
}

variable "secret_key" {
  type = string
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
resource "aws_cognito_user_pool" "user_pool" {
  name = "user-pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length = 6
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject = "Account Confirmation"
    email_message = "Your confirmation code is {####}"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "cognito-client"

  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  refresh_token_validity = 90
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
  
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = "gabrielaraujo"
  user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
}
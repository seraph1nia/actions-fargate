provider "aws" {
  region = "eu-central-1"
}

resource "aws_iam_user" "cognito_admin" {
  name = "ghactions-project-admin"
}

resource "aws_iam_access_key" "cognito_admin" {
  user = aws_iam_user.cognito_admin.name
}

resource "aws_iam_user_policy_attachment" "attach_cognito_power" {
  user       = aws_iam_user.cognito_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

resource "aws_cognito_user_pool" "ghactions-project" {
  name = "ghactions-project"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "ghactions-project-client" {
  name = "ghactions-project-client"

  user_pool_id = aws_cognito_user_pool.ghactions-project.id
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH","ALLOW_ADMIN_USER_PASSWORD_AUTH"]
}
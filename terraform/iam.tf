resource "aws_iam_role_policy" "controller_ssh_key" {
  name = "read-ssh-key-parameter"
  role = data.aws_iam_instance_profile.my_ssm_profile.role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:ap-southeast-1:${data.aws_caller_identity.my_account.account_id}:parameter/devops-project/ssh-PK"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "arn:aws:kms:ap-southeast-1:${data.aws_caller_identity.my_account.account_id}:alias/aws/ssm"
      }
    ]
  })
}
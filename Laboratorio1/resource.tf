
#### IAM ROLES FOR EC2 INSTANCE PROFILE ####
resource "aws_iam_role" "ec2-test-role" {
  name                = "ec2-test-role"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role_policy.json
  
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns) # toset vuelve una lista en un set, lo cual no permite duplicados
  role       = aws_iam_role.ec2-test-role.name
  policy_arn = each.value
}
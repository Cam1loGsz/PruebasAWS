module "ec2_instance" {
  source                 = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  name                   = "EC2-Test-Instance"
  ami                    = "ami-068c0051b15cdb816"
  instance_type          = "t3.micro"
  key_name               = "ec2-key-pair"     # Asegúrate de tener este par de llaves creado en tu cuenta de AWS
  user_data              = file("user_data.sh")
  vpc_security_group_ids = [module.security_group_ec2.security_group_id]
  subnet_id              = "subnet-04e7473716d36f167"
  iam_role_name          = aws_iam_role.ec2-test-role.name
}
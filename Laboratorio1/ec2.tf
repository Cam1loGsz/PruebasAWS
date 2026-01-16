# module "ec2_instance" {
#   source                 = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
#   name                   = "EC2-Instance"
#   ami                    = "ami-068c0051b15cdb816"
#   instance_type          = "t3.micro"
#   key_name               = "ec2-key-pair"     # Asegúrate de tener este par de llaves creado en tu cuenta de AWS
#   user_data              = file("user_data.sh")
#   vpc_security_group_ids = [module.security_group["ec2_tests_sg"].security_group_id]
#   subnet_id              = "subnet-04e7473716d36f167"
#   iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name
#   create_security_group  = false
# }
# module "ec2_instance_2" {
#   source                 = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
#   name                   = "EC2-Instance-2"
#   ami                    = "ami-068c0051b15cdb816"
#   instance_type          = "t3.micro"
#   key_name               = "ec2-key-pair"     # Asegúrate de tener este par de llaves creado en tu cuenta de AWS
#   user_data              = file("user_data.sh")
#   vpc_security_group_ids = [module.security_group["ec2_tests_sg"].security_group_id]
#   subnet_id              = "subnet-04e7473716d36f167"
#   iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name
#   create_security_group  = false
# }
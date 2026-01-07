module "ec2_instance" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  name   = "EC2-Test-Instance"
  ami    = "ami-068c0051b15cdb816"
  instance_type = "t3.micro"
  key_name      = "ec2-key-pair"
  user_data    = file("user_data.sh")
  vpc_security_group_ids = [module.security_group_ec2.this_security_group_id]
}
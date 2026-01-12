locals {
  vpc_id = "vpc-093b20febcca86e89"
}
locals {
  security_groups = {
    ec2_tests_sg = {
      vpc_id      = "vpc-093b20febcca86e89"
      name        = "ec2-sg"
      description = "Security Group for EC2 instance"
      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

  }
}
##### EBS VOLUME #####
resource "aws_ebs_volume" "volume2" {
  availability_zone = "us-east-1a"
  size              = 2

  tags = {
    Name = "EBS Volume for EC2 Instance"
  }
}

locals {
  vpc_id = "vpc-093b20febcca86e89"
}
locals {
  security_groups = {
    ec2_tests_sg = {
      vpc_id         = "vpc-093b20febcca86e89"
      sg_name        = "EC2-Tests-SG"
      sg_description = "Security Group for EC2 instance"
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
    ec2_tests_sg2 = {
      vpc_id         = "vpc-093b20febcca86e89"
      sg_name        = "EC2-Tests-SG2"
      sg_description = "Security Group for EC2 instance"
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

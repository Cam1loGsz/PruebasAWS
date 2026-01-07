module "security_group_ec2" {
    source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git"
    name   = "ec2-security-group"
    description = "Security group for EC2 instance"
    vpc_id = local.vpc_id
    ingress_with_cidr_blocks = [
        {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = "0.0.0.0/0"
        }
    ]
    egress_with_cidr_blocks = [
        {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = "0.0.0.0/0"
        }
    ]    
}
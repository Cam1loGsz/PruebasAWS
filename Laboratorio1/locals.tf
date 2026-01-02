locals {
  vpc_id = "vpc-093b20febcca86e89"
}
resource "aws_security_group" "sgtest" {
  name        = "sg-test"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = local.vpc_id

}
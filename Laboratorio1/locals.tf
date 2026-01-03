locals {
  vpc_id = "vpc-093b20febcca86e89"
}
resource "aws_security_group" "sgtest" {
  name        = "test-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = local.vpc_id

}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_outbound" {
  security_group_id = aws_security_group.sgtest.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
  description = "Allow all outbound traffic"
}
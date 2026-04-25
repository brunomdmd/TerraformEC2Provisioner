resource "aws_security_group" "sg_default" {
  name        = "SG-DEFAULT-${var.environment}"
  vpc_id      = var.vpc_id
  description = "Allow traffic inbound"

  tags = {
    Name     = "SG-${var.environment}"
    Ambiente = var.environment
  }

  ingress {
    description = "ALLOW-SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_ipv4, var.myip]
  }

  ingress {
    description = "ALLOW-RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.cidr_ipv4, var.myip]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

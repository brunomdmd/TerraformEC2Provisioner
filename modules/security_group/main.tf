resource "aws_security_group" "allow_ssh_http" {
  name        = "SG-ALLOW_SSH_HTTP-${var.environment}"
  vpc_id      = var.vpc_id
  description = "Allow traffic inbound SSH and HTTP and all outbound traffic"
    tags = {
        Name = "SG-ALLOW_SSH_HTTP-${var.environment}"
        Ambiente = var.environment
    } 

  ingress {
    description = "ALLOW-HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  ingress {
    description = "ALLOW-HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  ingress {
    description = "ALLOW-SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
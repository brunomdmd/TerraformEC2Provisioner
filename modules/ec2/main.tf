resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  count                  = var.instance_count
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_id

  root_block_device {
    encrypted = true
  }

  tags = {
    Name     = "EC2-${var.environment}-${format("%03d", count.index + 1)}"
    Ambiente = var.environment
  }
}

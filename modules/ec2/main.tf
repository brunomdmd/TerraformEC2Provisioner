resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  count                  = var.instance_count
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_id
  ebs_optimized          = true
  monitoring             = true
  metadata_options {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      instance_metadata_tags      = "enabled"
    }      
  root_block_device {
    encrypted = true
  }

  tags = {
    Name     = "${var.environment}-${var.os_type}-${var.subnet_name}-${format("%02d", count.index + 1)}"
    Ambiente = var.environment
    Servico = var.service
  }
}

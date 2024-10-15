resource "aws_instance" "web" {
  ami           = var.ami_id
  count         = var.instance_count
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = var.security_group_id
    tags = {
        Name = "WEB-${var.environment}-${count.index}"
        Ambiente = var.environment
    } 
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install nginx -y
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Servidor WEB</h1>" > /usr/share/nginx/html/index.html
  EOF
}
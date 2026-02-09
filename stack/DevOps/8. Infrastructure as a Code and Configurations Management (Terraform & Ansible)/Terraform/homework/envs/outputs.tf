output "alb_dns_name" { value = aws_lb.this.dns_name }
output "bastion_public_ip" { value = aws_instance.bastion.public_ip }


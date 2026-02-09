data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    set -ex
    
    amazon-linux-extras install nginx1 -y
    
    mkdir -p /usr/share/nginx/html/foo
    mkdir -p /usr/share/nginx/html/bar
    
    echo "<h1>${var.user_page_text}</h1>" > /usr/share/nginx/html/foo/index.html
    echo "<h1>${var.user_page_text}</h1>" > /usr/share/nginx/html/bar/index.html
    
    echo "<h1>${var.user_page_text}</h1>" > /usr/share/nginx/html/index.html
    
    systemctl enable nginx
    systemctl start nginx
    
    sleep 3
    curl -f http://localhost/ || exit 1
  EOT
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ssm_parameter.al2.value
  instance_type = var.instance_type
  user_data     = base64encode(local.user_data)
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_sg_id]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  tag {
    key                 = "Name"
    value               = "${var.name}-instance"
    propagate_at_launch = true
  }

  lifecycle { 
    create_before_destroy = true 
  }
}

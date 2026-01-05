data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "bastion" {
	ami = data.aws_ssm_parameter.al2.value
	instance_type = "t3.micro"
	subnet_id = module.vpc.public_subnets[0]
	vpc_security_group_ids = [aws_security_group.bastion.id]
	associate_public_ip_address = true
	key_name = var.bastion_key_name

	tags = { Name = "bastion" }
}

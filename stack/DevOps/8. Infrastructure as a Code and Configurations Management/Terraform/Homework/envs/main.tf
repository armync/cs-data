# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "hw-vpc"
  cidr = "10.0.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b"]
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support = true
  
  public_subnet_tags = { Tier = "public" }
  private_subnet_tags = { Tier = "private" }
}

module "foo_asg" {
  source            = "../modules/autoscale_nginx"
  name              = "foo"
  subnet_ids        = module.vpc.private_subnets
  app_sg_id         = aws_security_group.app.id
  user_page_text    = "Foo"
  target_group_arns = [aws_lb_target_group.foo.arn]
  key_name          = var.bastion_key_name
}

module "bar_asg" {
  source            = "../modules/autoscale_nginx"
  name              = "bar"
  subnet_ids        = module.vpc.private_subnets
  app_sg_id         = aws_security_group.app.id
  user_page_text    = "Bar"
  target_group_arns = [aws_lb_target_group.bar.arn]
  key_name          = var.bastion_key_name
}

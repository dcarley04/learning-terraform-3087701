data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

#data "aws_vpc" "default_vpc" {
#  default = true
#}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "dev"
  cidr            = "10.0.0.0/16"
  
  azs             = ["us-west-2a","us-west-2b","us-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blog" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  subnet_id              = module.blog_vpc.public_subnets[0]
  vpc_security_group_ids = [module.blog_sg.security_group_id]
  
  tags = {
    Name = "Learning Terraform"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id = module.blog_vpc.vpc_id
  name   = "blog"
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

#resource "aws_security_group" "web_blog_sg" {
#  name        = "web_blog_sg"
#  tags        = {
#    Terraform = "true"
#  }
#  vpc_id = data.aws_vpc.default_vpc.id
#}

#resource "aws_security_group_rule" "web_blog_sgr_http_in" {
#  type        = "ingress"
#  from_port   = 80
#  to_port     = 80
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.web_blog_sg.id
#}

#resource "aws_security_group_rule" "web_blog_sgr_https_in" {
#  type        = "ingress"
# from_port   = 443
#  to_port     = 443
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.web_blog_sg.id
#}

#resource "aws_security_group_rule" "web_blog_sgr_everything_out" {
#  type        = "egress"
#  from_port   = 0
#  to_port     = 0
#  protocol    = "-1"
#  cidr_blocks = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.web_blog_sg.id
#}
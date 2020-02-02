##############################################
# Build this example in US East (N. Virginia)
##############################################

provider "aws" {
  region = "us-east-1"
}

###############################
# Build a VPC for this example
###############################
locals {
  vpc_cidr     = "10.110.0.0/16"
  example_name = "common"
}

data "aws_availability_zones" "available" {}

resource "null_resource" "subnets" {
  count = length(data.aws_availability_zones.available.names)
  triggers = {
    private_subnet = cidrsubnet(local.vpc_cidr, 8, count.index + 1)
    public_subnet  = cidrsubnet(local.vpc_cidr, 8, count.index + 101)
  }
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.9.0"
  name                 = local.example_name
  cidr                 = local.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = null_resource.subnets.*.triggers.private_subnet
  public_subnets       = null_resource.subnets.*.triggers.public_subnet
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_s3_endpoint   = true
}

#########################################
# Build Jenkins Master as an ECS Service
#########################################

module "jenkins" {
  source                         = "git::ssh://git@gitlab.com/collabralink/delivery/terraform-aws-jenkins.git"
  name                           = local.example_name
  vpc_id                         = module.vpc.vpc_id
  host_instance_type             = "t3.small"
  host_key_name                  = "examples"
  auto_scaling_subnets           = [module.vpc.private_subnets[0]]
  auto_scaling_availability_zone = data.aws_availability_zones.available.names[0]
  load_balancer_subnets          = module.vpc.public_subnets
  fqdn                           = "jenkins-${local.example_name}.examples.cl-demo.com"
  fqdn_hosted_zone               = "cl-demo.com"
  fqdn_certificate_arn           = "arn:aws:acm:us-east-1:008087533974:certificate/d3303ea6-6bb5-4ae8-93cc-8bad2ddb1345"
}

############################################################################
# Open port 22 on the Jenkins ECS Host, maybe for development or debugging.
############################################################################
resource "aws_security_group_rule" "dev_public_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.jenkins.ecs_host_security_group_id
}

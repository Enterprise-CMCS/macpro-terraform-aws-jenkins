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
  vpc_cidr     = "10.112.0.0/16"
  example_name = "complete"
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
  source                         = "../.."
  name                           = local.example_name
  vpc_id                         = module.vpc.vpc_id
  host_instance_type             = "t3.small"
  host_key_name                  = "examples"
  auto_scaling_subnets           = [module.vpc.public_subnets[0]]
  auto_scaling_availability_zone = data.aws_availability_zones.available.names[0]
  load_balancer_subnets          = module.vpc.public_subnets
  fqdn                           = "jenkins-${local.example_name}.examples.cl-demo.com"
  fqdn_hosted_zone               = "cl-demo.com"
  fqdn_certificate_arn           = "arn:aws:acm:us-east-1:008087533974:certificate/d3303ea6-6bb5-4ae8-93cc-8bad2ddb1345"
  jenkins_home_size = "200"
}

###################################################################################
# Build an ECS Cluster to serve as a Jenkins Slave cluster launching Fargate tasks
###################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "template_file" "slave_ecs_cluster_policy_for_master" {
  template = file("./templates/slave-ecs-cluster-policy-for-master.json.tpl")
  vars = {
    region = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    cluster_name = module.jenkins.ecs_cluster_id
  }
}

resource "aws_iam_role_policy" "slave_ecs_cluster_policy_for_master" {
  name   = "jenkins-slave-ecs-cluster-policy-for-master-${local.example_name}"
  role       = module.jenkins.ecs_task_role_id
  policy = data.template_file.slave_ecs_cluster_policy_for_master.rendered
}

resource "aws_security_group_rule" "jenkins_slave_8080" {
  type            = "ingress"
  from_port       = 8080
  to_port         = 8080
  protocol        = "tcp"
  source_security_group_id = aws_security_group.jenkins_slave.id
  security_group_id = module.jenkins.ecs_host_security_group_id
}

resource "aws_security_group_rule" "jenkins_slave_50000" {
  type            = "ingress"
  from_port       = 50000
  to_port         = 50000
  protocol        = "tcp"
  source_security_group_id = aws_security_group.jenkins_slave.id
  security_group_id = module.jenkins.ecs_host_security_group_id
}

resource "aws_security_group" "jenkins_slave" {
  name        = "jenkins-slave-${local.example_name}"
  description = "Allow Jenkins Slaves outbound internet access"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "jenkins-slave-role-${local.example_name}"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "jenkins_fargate_jnlp_slave" {
  family                = "jenkins-fargate-jnlp-slave-${local.example_name}"
  container_definitions = <<EOF
[
  {
    "name": "jenkins_slave_terraform_resource",
    "image": "jenkins/jnlp-slave",
    "memoryReservation": 500,
    "essential": true
  }
]
EOF
  task_role_arn         = aws_iam_role.ecs_task.arn
  requires_compatibilities = ["FARGATE"]
  memory = "1024"
  cpu = 512
  network_mode = "awsvpc"
}

data "template_file" "slave_ecs_task_definition_policy_for_master" {
  template = file("./templates/slave-ecs-task-definition-policy-for-master.json.tpl")
  vars = {
    region = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    cluster_name = module.jenkins.ecs_cluster_id
    task_definition_name = aws_ecs_task_definition.jenkins_fargate_jnlp_slave.family
    pass_role_role = module.jenkins.ecs_task_role_id
  }
}

resource "aws_iam_role_policy" "slave_ecs_task_definition_policy_for_master" {
  name   = "jenkins-slave-ecs-task-definition-policy-for-master-${local.example_name}"
  policy = data.template_file.slave_ecs_task_definition_policy_for_master.rendered
  role = module.jenkins.ecs_task_role_id
}

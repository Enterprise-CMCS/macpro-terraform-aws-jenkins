
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "jenkins_host" {
  name        = "jenkins_ecs_${var.name}"
  description = "Allows 8080 traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_alb.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_ecs_cluster" "jenkins" {
  name = "jenkins_ecs_${var.name}"
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-ecs-hvm-*-x86_64-ebs",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.tpl")
  vars = {
    ecs_cluster_name = "jenkins_ecs_${var.name}"
  }
}

resource "aws_iam_role" "ecs_host" {
  name               = "jenkins-ecs-host-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Create an IAM policy for the jenkins instance, using the template rendered above.
resource "aws_iam_role_policy" "ecs_host" {
  name   = "jenkins-ecs-host-${var.name}"
  role   = aws_iam_role.ecs_host.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeTags",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DetachVolume",
        "ec2:AttachVolume",
        "ec2:CopySnapshot",
        "ec2:DeleteSnapshot",
        "ec2:ModifyVolumeAttribute",
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeSnapshotAttribute",
        "ec2:CreateTags",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumeAttribute",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeVolumeStatus",
        "ec2:ModifySnapshotAttribute",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeVolumes",
        "ec2:CreateSnapshot"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create an IAM profile for the jenkins host.
resource "aws_iam_instance_profile" "ecs_host" {
  name = "jenkins-ecs-host${var.name}"
  path = "/"
  role = aws_iam_role.ecs_host.name
}


resource "aws_launch_configuration" "jenkins" {
  name_prefix                 = "jenkins_ecs_${var.name}"
  image_id                    = data.aws_ami.ecs_optimized.id
  instance_type               = var.instance_type
  security_groups             = flatten([aws_security_group.jenkins_host.id, var.host_security_groups])
  key_name                    = var.host_key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ecs_host.name
  user_data                   = data.template_file.user_data.rendered
  root_block_device {
    volume_type = "gp2"
    volume_size = 500
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_jenkins" {
  name                      = "jenkins_ecs_${var.name}"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_configuration      = aws_launch_configuration.jenkins.name
  vpc_zone_identifier       = var.auto_scaling_subnets

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "jenkins_ecs_${var.name}"
      propagate_at_launch = true
    },
  ]
}

resource "aws_iam_role" "jenkins" {
  name               = "jenkins_ecs_${var.name}"
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

data "template_file" "ecs_task_jenkins_policy" {
  template = file("${path.module}/templates/ecs-task-jenkins-policy.tpl")
  vars = {
    jenkins_state_bucket = "asdf"
  }
}

resource "aws_iam_role_policy" "jenkins" {
  name   = "jenkins_ecs_${var.name}"
  policy = data.template_file.ecs_task_jenkins_policy.rendered
  role   = aws_iam_role.jenkins.id
}

data "template_file" "jenkins_task_template" {
  template = file("${path.module}/templates/jenkins.json.tpl")
  vars = {
    image = var.image
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  family                = "jenkins-ecs-${var.name}"
  container_definitions = data.template_file.jenkins_task_template.rendered
  network_mode          = "host"
  volume {
    name = "jenkins_home"
    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/ebs"
      driver_opts = {
        volume_type = "gp2"
        size        = "100"
      }
    }
  }
  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }
  volume {
    name      = "docker_bin"
    host_path = "/usr/bin/docker"
  }
  volume {
    name      = "docker_compose_bin"
    host_path = "/usr/local/bin/docker-compose"
  }
}

resource "aws_ecs_service" "jenkins" {
  name                              = "jenkins_ecs_${var.name}"
  cluster                           = aws_ecs_cluster.jenkins.id
  task_definition                   = aws_ecs_task_definition.jenkins.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 600

  load_balancer {
    target_group_arn = aws_alb_target_group.jenkins.id
    container_name   = "jenkins"
    container_port   = "8080"
  }

  depends_on = [aws_autoscaling_group.asg_jenkins]
}






resource "aws_security_group" "jenkins_alb" {
  name        = "jenkins_ecs_alb_${var.name}"
  description = "Allow 443 and 80"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_alb_target_group" "jenkins" {
  name                 = "jenkins-ecs-${var.name}"
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = "10"
  vpc_id               = var.vpc_id
  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200,403"
  }
  depends_on = [aws_alb.jenkins]
}

resource "aws_alb" "jenkins" {
  name            = "jenkins-ecs-${var.name}"
  subnets         = var.load_balancer_subnets
  security_groups = [aws_security_group.jenkins_alb.id]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.jenkins.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  default_action {
    target_group_arn = aws_alb_target_group.jenkins.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "http_to_https_redirect" {
  load_balancer_arn = aws_alb.jenkins.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.jenkins.id
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

data "aws_route53_zone" "zone" {
  name = var.hosted_zone
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.url
  type    = "CNAME"
  ttl     = "5"
  records = [aws_alb.jenkins.dns_name]
}

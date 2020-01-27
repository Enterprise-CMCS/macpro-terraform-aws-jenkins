
output "jenkins_slave_security_group_id" {
  description = "The ID of the security group to attach to Jenkins Slaves.  This can be used with the Jenkins ECS Plugin to launch Fargate slaves."
  value       = aws_security_group.jenkins_slave.id
}

output "jenkins_slave_subnets" {
  description = "Private subnets for Jenkins Slaves.  This can be used with the Jenkins ECS Plugin to launch Fargate slaves.  This is for convenience purposes only and not exclusive to Jenkins slaves.  This value really only represents the list of all private subnets in the VPC."
  value       = module.vpc.private_subnets
}

output "jenkins_slave_task_definition" {
  description = "The Fargate JNLP slave task definition family, or name.  This can be used with the Jenkins ECS Plugin to launch Fargate slaves."
  value = aws_ecs_task_definition.jenkins_fargate_jnlp_slave.family
}

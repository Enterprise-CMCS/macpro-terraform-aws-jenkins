
output "ecs_task_role_id" {
  description = "The IAM role ID attached to the ECS task.  This can be used to attach new policies to the running task."
  value       = aws_iam_role.ecs_task.id
}

output "ecs_host_role_id" {
  description = "The IAM role ID attached to the ECS host instance.  This can be used to attach new policies to the ECS host."
  value       = aws_iam_role.ecs_host.id
}

output "ecs_host_security_group_id" {
  description = "The ID of the security group used by the Jenkins auto scaling launch config."
  value       = aws_security_group.ecs_host.id
}

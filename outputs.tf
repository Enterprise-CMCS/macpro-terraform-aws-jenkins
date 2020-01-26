
output "ecs_task_role_id" {
  description = "The IAM role ID attached to the ECS task.  This can be used to attach new policies to the running task."
  value       = aws_iam_role.ecs_task.id
}

variable "auto_scaling_availability_zone" {
  description = "The single AZ into which Jenkins should be launched. "
  type        = string
}

variable "auto_scaling_subnets" {
  description = "The subnets for the Jenkins auto scaling group into which Jenkins may be placed."
  type        = list
}

variable "fqdn" {
  description = "The FQDN with which jenkins is accessed."
  type        = string
}

variable "fqdn_certificate_arn" {
  description = "The arn of the ACM certificate that gets applied to jenkins ALB.  This certificate should be valid for the supplied fqdn value."
  type        = string
}

variable "fqdn_hosted_zone" {
  description = "The hosted zone in which to create the route 53 record for jenkins.  The fqdn should fall inside this hosted zone."
  type        = string
}

variable "host_instance_type" {
  description = "Jenkins master instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "host_key_name" {
  description = "SSH key name in your AWS account for AWS instances."
  type        = string
}

variable "host_security_groups" {
  description = "Additional security groups to add to the jenkins host.  Warning:  These will only take affect when the next EC2 instance is launched by autoscaling.  You may want to use the ecs_host_security_group_id output to attach a new rule externally."
  default     = []
}

variable "image" {
  description = "Jenkins image to use"
  type        = string
  default     = "jenkins/jenkins:lts-centos"
}

variable "jenkins_home_size" {
  description = "The size in GB for the jenkins_home volume.  If using with jenkins_home_snapshot_id, size must be greater than the snapshot size."
  type        = string
  default     = "50"
}

variable "jenkins_home_snapshot_id" {
  description = "The snapshot ID from which to build the ebs volume."
  type        = string
  default     = ""
}

variable "load_balancer_subnets" {
  description = "The subnets the load balancer will include."
  type        = list
}

variable "name" {
  description = "Name for the Jenkins installation.  This is used in prefixes and suffixes."
  type        = string
}

variable "prefix" {
  description = "Prefix used in naming resources"
  type        = string
  default     = "jenkins"
}

variable "vpc_id" {
  description = "VPC ID into which Jenkins is launched."
  type        = string
}

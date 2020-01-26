
variable "name" {
  description = "Name for the Jenkins installation.  This is used in prefixes and suffixes."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID into which Jenkins is launched."
  type        = string
}

variable "load_balancer_subnets" {
  description = "The subnets the load balancer will include."
  type        = list
}

variable "auto_scaling_subnets" {
  description = "The subnets for the Jenkins auto scaling group into which Jenkins may be placed."
  type        = list
}

variable "host_security_groups" {
  description = "Additional security groups to add to the jenkins host"
  default     = []
}

variable "host_key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "instance_type" {
  description = "Jenkins master instance type"
  default     = "m5.xlarge"
}

variable "image" {
  description = "Jenkins image to use"
  default     = "jenkins/jenkins:lts-centos"
}

variable "certificate_arn" {
  description = "The arn of the ACM certificate to be applied to the jenkins ALB.  This certificate should be applicable to the jenkins_url variable"
}

variable "hosted_zone" {
  description = "The hosted zone in which to create the route 53 record for jenkins"
}

variable "url" {
  description = "The full url to the jenkins host"
}

variable "prefix" {
  description = "Prefix used in naming resources"
  type        = string
  default     = "jenkins"
}

variable "auto_scaling_availability_zone" {
  description = "The single AZ into which Jenkins should be launched. "
  type        = string
}

variable "jenkins_home_snapshot_id" {
  description = "The snapshot ID from which to build the ebs volume."
  type        = string
  default     = ""
}

variable "jenkins_home_size" {
  description = "The size in GB for the jenkins_home volume.  If using with jenkins_home_snapshot_id, size must be greater than the snapshot size."
  type        = string
  default     = "50"
}

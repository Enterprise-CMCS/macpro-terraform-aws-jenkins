
variable "vpc_cidr" {
  description = "Available CIDR for the vpc."
  type        = string
  default     = "10.151.0.0/16"
}

variable "name" {
  description = "This will be appended to many resource names."
  type        = string
  default     = "advanced"
}

variable "jenkins_fqdn" {
  description = "The desired FQDN for Jenkins."
  type        = string
  default     = "jenkins-advanced.examples.cl-demo.com"
}

variable "jenkins_fqdn_certificate_arn" {
  description = "The certificate to attach to Jenkins' load balancer.  This should be valid for the jenkins_fqdn specified above."
  type        = string
  default     = "arn:aws:acm:us-east-1:008087533974:certificate/d3303ea6-6bb5-4ae8-93cc-8bad2ddb1345"
}

variable "jenkins_hosted_zone" {
  description = "Route 53 hosted zone name.  This hosted_zone should contain the jenkins_fqdn specified above."
  type        = string
  default     = "cl-demo.com"
}

variable "jenkins_ecr_repo_name" {
  description = "A name for an ECR repo to contain the Jenkins master image."
  type        = string
  default     = "jenkins-advanced"
}

variable "jenkins_google_oauth_client_id" {
  description = "Google OAuth client id.  This is somewhat sensitive, so no default will be shown here.  Specify in a terraform.tfvars file."
  type        = string
}

variable "jenkins_google_oauth_client_secret" {
  description = "Google OAuth client secret.  This is somewhat sensitive, so no default will be shown here.  Specify in a terraform.tfvars file."
  type        = string
}

variable "jenkins_google_oauth_domain" {
  description = "Specifying a google domain here will restrict access to only members of that domain.  This is somewhat sensitive, so no default will be shown here.  Specify in a terraform.tfvars file."
  type        = string
}

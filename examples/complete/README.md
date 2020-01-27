# A common use case for this module.

This is a working terraform example that builds a VPC and a Jenkins with fairly common configuration.
Notably:
- The image variable is not specified, leaving the module default (jenkins/jenkins:lts-centos) in force.
- A custom instance type is specified for the ECS Host.  (t3.small is uncommonly small, but overriding the default value is common)
- private subnets are passed to auto_scaling_subnets, indicating the Jenkins host should not be publicly accessible.
- public subnets are passed to load_balancer_subnets, indicating the load balancer should be publicly available to serve traffic to and from the private Jenkins host.

## Usage

Currently, there are a few prerequisites to running this code as is:
1. Update the fqdn_* variables to something appropriate for your account and installation.
4. Update the key_name variable with the name of an EC2 key pair that already exists.  Create a key pair if needed.
5. Run:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Notes

Please reference the inputs/outputs documentation in the top level README for more information.

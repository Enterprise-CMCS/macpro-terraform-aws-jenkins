# A common use case for this module.

This is a working terraform example that builds a VPC and a Jenkins with fairly common configuration.
Notably:
- The image variable is not specified, leaving the module default (jenkins/jenkins:lts-centos) in force.
- A custom instance type is specified for the ECS Host.  (t3.small is uncommonly small, but overriding the default value is common)
- private subnets are passed to auto_scaling_subnets, indicating the Jenkins host should not be publicly accessible.

## Usage

Currently, there are a few prerequisites to running this code as is:
1. Update the hosted_zone variable with an AWS Route53 hosted zone for which you have permissions to edit.  Purchase a domain through Route53 if needed.
2. Update the url variable accordingly, ensuring it falls within your hosted zone.
3. Update the certificate_arn variable; this should be a certificate in ACM that is valid for the assigned url.
4. Update the key_name variable with the name of an EC2 key pair that already exists.  Create a key pair if needed.
5. Run:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Notes

Please reference the inputs/outputs documentation in the top level README for more information.

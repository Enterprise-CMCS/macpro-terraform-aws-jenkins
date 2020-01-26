# Jenkins ECS Terraform Module

A containerized Jenkins Master implementation orchestrated by ECS.


## Terraform versions

Terraform 0.12 +


## Usage
See a common implementation (complete with VPC) [here!](examples/common)

```hcl
module "jenkins" {
  source                         = "git::ssh://git@gitlab.com/mdialcollabralinkcom/jenkins-ecs.git"
  name                           = "jenkins"
  vpc_id                         = "vpc-abc123"
  instance_type                  = "t3.large"
  host_key_name                  = "myEC2KeyPair"
  auto_scaling_subnets           = ["subnet-123afb39d0dagdv32",subnet-004aff23j60dwez897"]
  auto_scaling_availability_zone = "us-east-1a"
  load_balancer_subnets          = ["subnet-277afb45g0dagdv32",subnet-3288vvssdwezf221xv"]
  url                            = "jenkins.mydomain.com"
  hosted_zone                    = "mydomain.com"
  certificate_arn                = "arn:aws:acm:us-east-1:02333354974:certificate/dsav3ea6-6ff5-31e8-93cc-8badfdvzf1345"
}
```


## Examples
See a common implementation (complete with VPC)  [here!](examples/common)


## Contributing / To-Do
WIP


## Notes

WIP


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| auto\_scaling\_availability\_zone | The single AZ into which Jenkins should be launched. | string | n/a | yes |
| auto\_scaling\_subnets | The subnets for the Jenkins auto scaling group into which Jenkins may be placed. | list | n/a | yes |
| certificate\_arn | The arn of the ACM certificate to be applied to the jenkins ALB.  This certificate should be applicable to the jenkins_url variable | string | n/a | yes |
| host\_key\_name | SSH key name in your AWS account for AWS instances. | string | n/a | yes |
| host\_security\_groups | Additional security groups to add to the jenkins host | list | `[]` | no |
| hosted\_zone | The hosted zone in which to create the route 53 record for jenkins | string | n/a | yes |
| image | Jenkins image to use | string | `"jenkins/jenkins:lts-centos"` | no |
| instance\_type | Jenkins master instance type | string | `"m5.xlarge"` | no |
| jenkins\_home\_size | The size in GB for the jenkins_home volume.  If using with jenkins_home_snapshot_id, size must be greater than the snapshot size. | string | `"50"` | no |
| jenkins\_home\_snapshot\_id | The snapshot ID from which to build the ebs volume. | string | `""` | no |
| load\_balancer\_subnets | The subnets the load balancer will include. | list | n/a | yes |
| name | Name for the Jenkins installation.  This is used in prefixes and suffixes. | string | n/a | yes |
| prefix | Prefix used in naming resources | string | `"jenkins"` | no |
| url | The full url to the jenkins host | string | n/a | yes |
| vpc\_id | VPC ID into which Jenkins is launched. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_host\_role\_id | The IAM role ID attached to the ECS host instance.  This can be used to attach new policies to the ECS host. |
| ecs\_task\_role\_id | The IAM role ID attached to the ECS task.  This can be used to attach new policies to the running task. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Currently maintained by [these contributors](https://gitlab.com/mdialcollabralinkcom/jenkins-eks/-/graphs/master) at Collabralink Technologies, Inc.
Module managed by [Mike Dial](https://gitlab.com/mdialcollabralinkcom).

## License

Collabralink use only until advised differently (not a lawyer).

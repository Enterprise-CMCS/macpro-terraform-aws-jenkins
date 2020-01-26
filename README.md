# Jenkins EKS

Terraform module which:
- Creates a Jenkins Master orchestrated with EKS.


## Terraform versions

Terraform 0.12 is supported.


## Usage
WIP

## Examples
WIP

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
| load\_balancer\_subnets | The subnets the load balancer will include. | list | n/a | yes |
| name | Name for the Jenkins installation.  This is used in prefixes and suffixes. | string | n/a | yes |
| prefix | Prefix used in naming resources | string | `"jenkins"` | no |
| url | The full url to the jenkins host | string | n/a | yes |
| vpc\_id | VPC ID into which Jenkins is launched. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Currently maintained by [these contributors](https://gitlab.com/mdialcollabralinkcom/jenkins-eks/-/graphs/master) at Collabralink Technologies, Inc.
Module managed by [Mike Dial](https://gitlab.com/mdialcollabralinkcom).

## License

Collabralink use only until advised differently (not a lawyer).

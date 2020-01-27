# A more complete implementation of this module.

This is a working example of a more complete implementation of the terraform-aws-jenkins module.
Notably:
- An ecs slave cluster is built external to the module
- Module output is used to attach new security group rules to the Jenkins ecs task.
- Module output is used again to attach new policies to the Jenkins ecs task role.
- A typical jenkins-jnlp-slave task definition is created.  This is what Jenkins will launch.
- The example spits out the output needed to configure Jenkins Master to launch Fargate slaves on demand using the ECS plugin.


## Usage

Currently, there are a few prerequisites to running this code as is:
1. Update the fqdn_* variables to something appropriate for your account and installation.
2. Update the key_name variable with the name of an EC2 key pair that already exists.  Create a key pair if needed.
3. Run:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
After creation, install the ECS plugin from the Jenkins UI, and configure it per https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Container+Service+Plugin  The values outputted from this module should be all the cluster specific values you need.


## Notes

Please reference the inputs/outputs documentation in the top level README for more information.

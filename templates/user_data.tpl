#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
yum update -y
dockergid=`echo $(getent group docker) | cut -d: -f3`
chown 1000:$dockergid /var/run/docker.sock
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=us-east-1 --grant-all-permissions
echo ECS_CLUSTER='${ecs_cluster_name}' >> /etc/ecs/ecs.config
echo END

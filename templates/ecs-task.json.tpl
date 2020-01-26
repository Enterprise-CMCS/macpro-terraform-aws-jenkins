[
  {
    "name": "jenkins",
    "image": "${image}",
    "memory": 8192,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      },
      {
        "containerPort": 50000,
        "hostPort": 50000
      },
      {
	"containerPort": 8980,
	"hostPort": 8980
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/var/jenkins_home",
        "sourceVolume": "${ebs_volume_name}",
        "readOnly": null
      },
      {
        "containerPath": "/var/run/docker.sock",
        "sourceVolume": "docker_sock"
      },
      {
        "containerPath": "/usr/bin/docker",
        "sourceVolume": "docker_bin"
      }
    ]
  }
]

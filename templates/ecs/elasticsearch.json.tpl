[
  {
    "name": "elasticsearch",
    "image": "${app_image_elasticsearch}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/elasticsearch",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port_es1},
        "hostPort": ${app_port_es1},
        "containerPort": ${app_port_es2},
        "hostPort": ${app_port_es2}
      }
    ],
        "environment": [ 
      {
        "name": "VARNAME",
        "DISCOVERY_TYPE":	"single-node",
         "discovery.type":	"single-node",
         "ELASTIC_PASSWORD":	"SGTelk123!",
         "ELASTICSEARCH_SKIP_TRANSPORT_TLS":	"true",
          "ES_JAVA_OPTS":	    "-Xms512m -Xmx512m"
      }]
      ,

      "MountPoints": [
        {
          "ContainerPath": "/usr/share/elasticsearch/data",
          "SourceVolume": "ELK-efs"
        }
      
      ]

  }   
]
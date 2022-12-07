# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "ap-southeast-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image_logstash" {
  description = "Logstash image to run in the ECS cluster"
  default     = "818682305270.dkr.ecr.ap-southeast-1.amazonaws.com/dev-elk:logstash"
}

variable "app_image_elasticsearch" {
  description = "Elasticsearch image to run in the ECS cluster"
  default     = "818682305270.dkr.ecr.ap-southeast-1.amazonaws.com/dev-elk:elasticsearch"
}

variable "app_image_kibana" {
  description = "Kibana image to run in the ECS cluster"
  default     = "818682305270.dkr.ecr.ap-southeast-1.amazonaws.com/dev-elk:kibana"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_port_es1" {
description = "Port mapping for elasticsearch"
default = 9200
}

variable "app_port_es2" {
description = "Port mapping for elasticsearch"
default = 9300
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "env" {
  description = "ECS Cluster environment"
  default     = "dev"
}
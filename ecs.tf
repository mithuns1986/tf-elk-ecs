# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "${lower(var.env)}-elk-cluster"
}

data "template_file" "logstash" {
  template = file("./templates/ecs/logstash.json.tpl")

  vars = {
    app_image_logstash      = var.app_image_logstash
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

data "template_file" "elasticsearch" {
  template = file("./templates/ecs/elasticsearch.json.tpl")

  vars = {
    app_image_elasticsearch      = var.app_image_elasticsearch
    app_port_es1       = var.app_port_es1
    app_port_es2       = var.app_port_es2
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

data "template_file" "kibana" {
  template = file("./templates/ecs/kibana.json.tpl")

  vars = {
    app_image_kibana      = var.app_image_kibana
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "logstash" {
  family                   = "${lower(var.env)}-logstash"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.logstash.rendered
}

resource "aws_ecs_task_definition" "elasticsearch" {
  family                   = "elasticsearch"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  #container_definitions    = data.template_file.elasticsearch.rendered
  container_definitions    = jsonencode([
    {
      name      = "elasticsearch"
      image     = var.app_image_elasticsearch
      cpu       = var.fargate_cpu
      memory    = var.fargate_memory
      network_mode = "awsvpc"
      essential = true
      logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/Dev-CDI-ELK-task"
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.aws_region
      }
    }
      portMappings = [
        {
          containerPort = 9200
          hostPort      = 9200
        }
      ]
    
    {
    environment = [
        {
          #{"name": "DISCOVERY_TYPE", "value": "single-node", "name": "ELASTIC_PASSWORD":, "value": "SGTelk123!", "name": "ELASTICSEARCH_SKIP_TRANSPORT_TLS", "value": "true", "name": "ES_JAVA_OPTS",	"value": "-Xms512m "\"-Xmx512m"}
          
	        "DISCOVERY_TYPE": "single-node",
	        "ELASTIC_PASSWORD": "SGTelk123!",
	        "ELASTICSEARCH_SKIP_TRANSPORT_TLS": "true",
	        "ES_JAVA_OPTS": "-Xms512m -Xmx512m"      
        }
      ]
    }
    }
  ]) 
  volume {
    name = "ELK-efs"

    efs_volume_configuration {
      file_system_id          = "fs-0665fc29086582a75"
      root_directory          = "/"
      transit_encryption      = "ENABLED"
    }
  }
}

resource "aws_ecs_task_definition" "kibana" {
  family                   = "kibana"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.kibana.rendered
}

resource "aws_ecs_service" "logstash" {
  name            = "logstash"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.logstash.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
    network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "elk"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_ecs_service" "elasticsearch" {
  name            = "elasticsearch"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.elasticsearch.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "elasticsearch"
    #container_port   = var.app_port_es1
    container_port   = "9200"
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_ecs_service" "kibana" {
  name            = "kibana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kibana.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "elk"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
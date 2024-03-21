resource "aws_ecs_cluster" "liferay_cluster" {
  name = "liferay-cluster"
}

resource "aws_ecs_task_definition" "liferay_task" {
  family                   = "liferay-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "8192"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "liferay",
      image     = var.liferay_image,
      cpu       = 2048,
      memory    = 8192,
      essential = true,
      environment = [
        {
          name  = "LIFERAY_VIRTUAL_PERIOD_HOSTS_PERIOD_VALID_PERIOD_HOSTS"
          value = "*"
        },
        {
          name  = "LIFERAY_AUTO_PERIOD_DEPLOY_PERIOD_DEPLOY_PERIOD_DIR"
          value = "/mnt/liferay/deploy"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "liferay-deploy"
          containerPath = "/mnt/liferay/deploy"
          readOnly      = false
        }
      ]

      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.liferay_log_group.name
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "liferay-deploy"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.liferay_efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }

  depends_on = [ aws_efs_file_system.liferay_efs ]

}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
        Effect = "Allow",
        Sid    = "",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "liferay_service" {
  name            = "liferay-service"
  cluster         = aws_ecs_cluster.liferay_cluster.id
  task_definition = aws_ecs_task_definition.liferay_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  depends_on = [
    aws_alb_listener.liferay_listener,
  ]

  load_balancer {
    target_group_arn = aws_alb_target_group.liferay_tg.arn
    container_name   = "liferay"
    container_port   = 8080
  }


  network_configuration {
    subnets          = aws_subnet.ecs_subnet[*].id # Specify your subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.liferay_sg.id] # Specify your security group
  }

}

resource "aws_cloudwatch_log_group" "liferay_log_group" {
  name = "/ecs/liferay"
}

resource "aws_alb" "liferay_alb" {
  name               = "liferay-alb"
  internal           = false
  load_balancer_type = "application"
  # security_groups    = [aws_security_group.liferay_sg.id]
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = aws_subnet.ecs_subnet[*].id
}

resource "aws_alb_target_group" "liferay_tg" {
  name        = "liferay-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"
  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_alb_listener" "liferay_listener" {
  load_balancer_arn = aws_alb.liferay_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.liferay_tg.arn
  }
}

resource "aws_iam_policy_attachment" "ecs_efs_policy_attachment" {
  name       = "ecs-efs-access-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.efs_access_policy.arn
}

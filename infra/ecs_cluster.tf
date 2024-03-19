resource "aws_ecs_cluster" "liferay_cluster" {
  name = "liferay-cluster"
}

resource "aws_ecs_task_definition" "liferay_task" {
  family                = "liferay-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "2048"
  memory                = "4096"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "liferay",
      image     = var.liferay_image,
      cpu       = 2048,
      memory    = 4096,
      essential = true,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ]
    }
  ])
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

  network_configuration {
    subnets         = aws_subnet.ecs_subnet[*].id # Specify your subnets
    assign_public_ip = true
    security_groups = [aws_security_group.liferay_sg.id] # Specify your security group
  }

  desired_count = 1
}


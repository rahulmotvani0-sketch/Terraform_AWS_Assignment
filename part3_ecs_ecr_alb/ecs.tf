# ------------------------------------------------------------------------------
# AWS ECS Fargate Cluster, Task Definitions, and Service
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-fullstack-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for ECS Containers
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.environment}-fullstack-app"
  retention_in_days = 7
}

# Full-Stack Fargate Task Definition (Dual-Container Pod Pattern)
resource "aws_ecs_task_definition" "fullstack_task" {
  family                   = "${var.environment}-fullstack-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-backend"
      image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "PORT", value = "5000" },
        { name = "PYTHONUNBUFFERED", value = "1" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    },
    {
      name      = "express-frontend"
      image     = "${aws_ecr_repository.frontend_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "PORT", value = "3000" },
        { name = "NODE_ENV", value = "production" },
        { name = "BACKEND_URL", value = "http://localhost:5000" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])
}

# ECS Fargate Service
resource "aws_ecs_service" "main" {
  name            = "${var.environment}-fullstack-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.fullstack_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "express-frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}

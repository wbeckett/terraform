variable "ports" {
  type    = map(number)
  default = {
    HTTP  = 80
  }
}

resource "aws_lb" "test" {
  name               = "${local.workspace_title}-test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Environment = "production"
  }
}

resource "aws_alb_target_group" "test" {
  for_each = var.ports

  port        = each.value
  protocol    = each.key
  vpc_id      = aws_vpc.default.id

  depends_on = [
    aws_lb.test
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "test" {
  for_each = var.ports

  load_balancer_arn = aws_lb.test.arn

  protocol          = each.key
  port              = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.test[each.key].arn
  }
}


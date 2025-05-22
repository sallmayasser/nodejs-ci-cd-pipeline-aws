resource "aws_lb" "my-ALB" {
  name                       = var.alb-name
  internal                   = var.isInternal
  load_balancer_type         = "application"
  security_groups            = var.security-group-ids
  subnets                    = var.subnet-ids
  enable_deletion_protection = false

}

resource "aws_lb_target_group" "my-target-group" {
  name     = var.target-gp-name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
}

resource "aws_lb_target_group_attachment" "my-target-group-attachment" {
  target_group_arn = aws_lb_target_group.my-target-group.arn
  for_each         = var.target-group-list-id
  target_id        = each.value
  port             = 80
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.my-ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}

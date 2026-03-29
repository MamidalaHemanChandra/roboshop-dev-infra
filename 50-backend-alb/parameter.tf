resource "aws_ssm_parameter" "backend-alb" {
  name  = "/${var.project}/${var.environment}/backend-alb"
  type  = "String"
  value = aws_lb_listener.backend-alb.arn
  overwrite = true
}

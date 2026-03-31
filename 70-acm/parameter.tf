resource "aws_ssm_parameter" "frontend_certificate_arn" {
  name  = "/${var.project}/${var.environment}/frontend_certificate_arn"
  type  = "String"
  value = aws_acm_certificate.roboshop.arn
}

data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_ssm_parameter" "frontend_certificate_arn" {
  name = "/${var.project}/${var.environment}/frontend_certificate_arn"
}
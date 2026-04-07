locals {
    caching_optimized = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    caching_disabled = data.aws_cloudfront_cache_policy.managed_caching_disabled.id  
    cdn_certificate_arn =  data.aws_ssm_parameter.frontend_certificate_arn
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
    common_name = "${var.project}-${var.environment}" 
}
resource "aws_instance" "open_vpn" {
    ami                     = local.open_vpn
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.open_vpn_sg_id]
    subnet_id = local.subnet_id
    user_data = file("vpn.sh")


    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-open_vpn"
    }
  )
}

resource "aws_route53_record" "open_vpn" {
  zone_id = var.zone_id
  name    = "open_vpn.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.open_vpn.public_ip]
  allow_overwrite = true
}
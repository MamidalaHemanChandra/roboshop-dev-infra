resource "aws_instance" "bastion" {
    ami                     = local.ami_id
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.bastion_sg_id]
    subnet_id = local.subnet_id
    user_data = file("bastion.sh")

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-bastion"
    }
  )
}
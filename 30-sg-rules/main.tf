resource "aws_security_group_rule" "backend-alb-bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = local.backend_alb_sg_id
  source_security_group_id = local.bastion_sg_id
}

resource "aws_security_group_rule" "bastion-laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = local.bastion_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
}
#catalogue
resource "aws_instance" "catalogue" {
    ami                     = local.ami_id
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.catalogue_sg_id]
    subnet_id = local.private_subnet_id

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue"
    }
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
   type = "ssh"
   user = "ec2-user"
   password = "DevOps321"
   host = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
   source = "catalogue.sh"
   destination = "/tmp/catalogue.sh"
  }

  provisioner "remote-exec" {
   inline = [
       "chmod +x /tmp/catalogue.sh",
       "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"
   ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state = "stopped"
  depends_on = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.common_name}-catalogue-ami"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [aws_ec2_instance_state.catalogue]
}

resource "aws_lb_target_group" "catalogue" {
  name = "${local.common_name}-catalogue"
  port = 8080
  protocol = "HTTP"
  vpc_id = local.vpc_id
  deregistration_delay = 60

  health_check {
    path = "/health"
    protocol = "HTTP"
    interval = 10
    timeout = 3
    port = 8080
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200-299"
  }
}


resource "aws_launch_template" "catalogue" {
  name = "${local.common_name}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id

  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [local.catalogue_sg_id]

  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue"
    }
  )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue"
    }
  )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue"
    }
  )
}

resource "aws_autoscaling_group" "catalogue" {
  name                      = "${local.common_name}-catalogue"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  launch_template {
    id = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }
  target_group_arns = [aws_lb_target_group.catalogue.arn]
  vpc_zone_identifier       = local.private_subnet_ids

   instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }


  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${local.common_name}-catalogue"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
    
  }

  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${local.common_name}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend-alb
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${domain_name}"]
    }
  }
}
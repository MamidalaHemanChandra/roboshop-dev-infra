#mongodb
resource "aws_instance" "mongodb" {
    ami                     = local.ami_id
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.mongodb_sg_id]
    subnet_id = local.database_subnet_id

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-mongodb"
    }
  )
}

resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id
  ]

  connection {
   type = "ssh"
   user = "ec2-user"
   password = "DevOps321"
   host = aws_instance.mongodb.private_ip
  }

  provisioner "file" {
   source = "bootstrap.sh"
   destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
   inline = [
       "chmod +x /tmp/bootstrap.sh",
       "sudo sh /tmp/bootstrap.sh mongodb"
   ]
  }
}

#redis
resource "aws_instance" "redis" {
    ami                     = local.ami_id
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.redis_sg_id]
    subnet_id = local.database_subnet_id

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-redis"
    }
  )
}

resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  connection {
   type = "ssh"
   user = "ec2-user"
   password = "DevOps321"
   host = aws_instance.redis.private_ip
  }

  provisioner "file" {
   source = "bootstrap.sh"
   destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
   inline = [
       "chmod +x /tmp/bootstrap.sh",
       "sudo sh /tmp/bootstrap.sh redis"
   ]
  }
}

#rabbitmq
resource "aws_instance" "rabbitmq" {
    ami                     = local.ami_id
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.rabbitmq_sg_id]
    subnet_id = local.database_subnet_id

    tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-rabbitmq"
    }
  )
}

resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  connection {
   type = "ssh"
   user = "ec2-user"
   password = "DevOps321"
   host = aws_instance.rabbitmq.private_ip
  }

  provisioner "file" {
   source = "bootstrap.sh"
   destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
   inline = [
       "chmod +x /tmp/bootstrap.sh",
       "sudo sh /tmp/bootstrap.sh rabbitmq"
   ]
  }
}

#IAM Policy for SSM Parameter Store
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "ssm-parameter-store-policy"
  description = "Policy for accessing SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:PutParameter",
          "ssm:DeleteParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/*"
      }
    ]
  })
}

#IAM Role
resource "aws_iam_role" "ssm_role" {
  name = "ssm-parameter-store-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#Attach Policy to Role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.ssm_parameter_policy.arn
}

# #IAM Instance Profile
# resource "aws_iam_instance_profile" "ssm_profile" {
#   name = "ssm-instance-profile"
#   role = aws_iam_role.ssm_role.name
# }

# #mysql
# resource "aws_instance" "mysql" {
#     ami                     = local.ami_id
#     instance_type           = "t3.micro"
#     vpc_security_group_ids  = [local.mysql_sg_id]
#     subnet_id = local.database_subnet_id
#     iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

#     tags = merge(
#     local.common_tags,
#     {
#       Name = "${local.common_name}-mysql"
#     }
#   )
# }

# resource "terraform_data" "mysql" {
#   triggers_replace = [
#     aws_instance.mysql.id
#   ]

#   connection {
#    type = "ssh"
#    user = "ec2-user"
#    password = "DevOps321"
#    host = aws_instance.mysql.private_ip
#   }

#   provisioner "file" {
#    source = "bootstrap.sh"
#    destination = "/tmp/bootstrap.sh"
#   }

#   provisioner "remote-exec" {
#    inline = [
#        "chmod +x /tmp/bootstrap.sh",
#        "sudo sh /tmp/bootstrap.sh mysql"
#    ]
#   }
# }


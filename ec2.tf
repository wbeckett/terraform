#variable "user_data_script" {
#  type    = string
#  default = <<EOF
##!/bin/bash
#
#touch /root/.user_data
#yum update -y
#yum install httpd -y
#systemctl enable httpd
#echo "Hello New" > /var/www/htdocs/index.html
#reboot
#
#EOF
#
#}

resource "aws_instance" "App_server_1a" {
  ami                  = "ami-033b95fb8079dc481"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.public-subnet-a.id
  iam_instance_profile = aws_iam_instance_profile.profile_instance.name
  user_data            = var.user_data_script
  key_name             = "ssh-key"

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = {
    Name = "${local.workspace_title}_App_server_1a"
  }

}

resource "aws_instance" "App_server_2b" {
  ami                  = "ami-033b95fb8079dc481"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.public-subnet-b.id
  iam_instance_profile = aws_iam_instance_profile.profile_instance.name
  user_data            = var.user_data_script
  key_name             = "ssh-key"

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = {
    Name = "${local.workspace_title}_App_server_2b"
  }

}

resource "aws_instance" "App_server_1b" {
  ami                  = "ami-033b95fb8079dc481"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.public-subnet-b.id
  iam_instance_profile = aws_iam_instance_profile.profile_instance.name
  user_data            = var.user_data_script
  key_name             = "ssh-key"

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = {
    Name = "${local.workspace_title}_App_server_1b"
  }

}

resource "aws_instance" "App_server_2a" {
  ami                  = "ami-033b95fb8079dc481"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.public-subnet-a.id
  iam_instance_profile = aws_iam_instance_profile.profile_instance.name
  user_data            = var.user_data_script
  key_name             = "ssh-key"

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = {
    Name = "${local.workspace_title}_App_server_2a"
  }

}


resource "aws_alb_target_group_attachment" "App_server_1a" {
  for_each = var.ports

  target_group_arn = aws_alb_target_group.test[each.key].arn
  target_id        = aws_instance.App_server_1a.id
  port             = each.value
}

resource "aws_alb_target_group_attachment" "App_server_2a" {
  for_each = var.ports

  target_group_arn = aws_alb_target_group.test[each.key].arn
  target_id        = aws_instance.App_server_2a.id
  port             = each.value
}

resource "aws_alb_target_group_attachment" "App_server_1b" {
  for_each = var.ports

  target_group_arn = aws_alb_target_group.test[each.key].arn
  target_id        = aws_instance.App_server_1b.id
  port             = each.value
}

resource "aws_alb_target_group_attachment" "App_server_2b" {
  for_each = var.ports

  target_group_arn = aws_alb_target_group.test[each.key].arn
  target_id        = aws_instance.App_server_2b.id
  port             = each.value
}

output "aws_ec2_ip_App_server_1a" {
  value = aws_instance.App_server_1a.public_ip
}

output "aws_ec2_ip_App_server_1b" {
  value = aws_instance.App_server_1b.public_ip
}

output "aws_ec2_ip_App_server_2a" {
  value = aws_instance.App_server_2a.public_ip
}

output "aws_ec2_ip_App_server_2b" {
  value = aws_instance.App_server_2b.public_ip
}


resource "aws_instance" "app_server_1" {
  ami           = "ami-033b95fb8079dc481"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-a.id

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = {
    Name = "app_server_1"
  }

  user_data = <<EOF
#!/bin/bash

touch /root/.user_data
yum update -y
yum install httpd -y
systemctl enable httpd
reboot

EOF

}

resource "aws_instance" "app_server_2" {
  ami           = "ami-033b95fb8079dc481"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-b.id

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = {
    Name = "app_server_2"
  }

  user_data = <<EOF
#!/bin/bash

touch /root/.user_data
yum update -y
yum install httpd -y
systemctl enable httpd
reboot

EOF

}

resource "aws_alb_target_group_attachment" "app_server_1" {
  for_each = var.ports

  target_group_arn = aws_alb_target_group.test[ each.key ].arn
  target_id        = aws_instance.app_server_1.id
  port             = each.value
}

resource "aws_alb_target_group_attachment" "app_server_2" {
  for_each = var.ports

  target_group_arn = aws_alb_target_group.test[ each.key ].arn
  target_id        = aws_instance.app_server_2.id
  port             = each.value
}


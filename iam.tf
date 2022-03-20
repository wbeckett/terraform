locals {
  iam_role     = "EC2-Role-${terraform.workspace}"
  iam_instance = "EC2-Role-Instance-${terraform.workspace}"
}



resource "aws_iam_role" "role" {
  name = local.iam_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "AMP_Write" {
  role       = local.iam_role
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
  depends_on = [aws_iam_role.role]
}

resource "aws_iam_instance_profile" "profile_instance" {
  name = local.iam_instance
  role = local.iam_role
}

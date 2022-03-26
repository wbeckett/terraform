# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace

resource "aws_grafana_workspace" "example" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "CUSTOMER_MANAGED"
  role_arn                 = aws_iam_role.GrafanaRole.arn
  data_sources             = ["PROMETHEUS"]

}

resource "aws_iam_role" "GrafanaRole" {
  name = "grafana-${local.workspace_title}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "GrafanaPrometheusPolicy" {
  name = "GrafanaPrometheusPolicy"

  policy = jsonencode({
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aps:ListWorkspaces",
                "aps:DescribeWorkspace",
                "aps:QueryMetrics",
                "aps:GetLabels",
                "aps:GetSeries",
                "aps:GetMetricMetadata"
            ],
            "Resource": "*"
        }
    ]

  })
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.GrafanaRole.name
  policy_arn = aws_iam_policy.GrafanaPrometheusPolicy.arn
}

# AWS Prometheus workspace ( AMP ).
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace

locals {
  amp_name = "amp-${terraform.workspace}"
}

resource "aws_prometheus_workspace" "amp_1" {
  # The alias is also known as The Workspace Alias
  alias = "prometheus-test-${local.amp_name}"

  tags = {
    Environment = "production"
    Owner       = "abhi"
  }
}

# Create IAM role



output "amp_arn" {
  value = aws_prometheus_workspace.amp_1.arn
}

output "amp_endpoint" {
  value = aws_prometheus_workspace.amp_1.prometheus_endpoint
}

output "amp_id" {
  value = aws_prometheus_workspace.amp_1.id
}




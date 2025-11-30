# Creates IAM role that GitHub Actions will assume via OIDC
resource "aws_iam_openid_connect_provider" "github" {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub OIDC thumbprint
}

data "aws_iam_policy_document" "github_assume_role" {
    statement {
        effect = "Allow"
        principals {
            type = "Federated"
            identifiers = [aws_iam_openid_connect_provider.github.arn]
        }
        actions = ["sts:AssumeRoleWithWebIdentity"]
        condition {
            test = "StringLike"
            values = ["repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"]
            variables = ["token.actions.githubusercontent.com:sub"]
        }
    }
}

resource "aws_iam_role" "github_actions" {
    name = "${var.app_name}-github-actions-role"
    assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

resource aws_ecr_repository ecr_repository {
  name = "prediction"
}

resource aws_ecr_repository_policy ecr_repository_policy {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = data.aws_iam_policy_document.ecr_repository_policy.json
}


data aws_iam_policy_document ecr_repository_policy {
  statement {
    sid = "AllowEcsTasks"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
    ]

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.workspace_account_ids)
    }
  }
}


data aws_ecr_repository baseimage {
  name = "docker-baseimage"
}

data aws_ecr_repository codebuild {
  name = "docker-baseimage/codebuild"
}

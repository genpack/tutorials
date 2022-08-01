resource "aws_codebuild_project" "build" {
  name         = "prediction-cicd-pytest"
  service_role = data.aws_iam_role.codebuild.arn

  source {
    buildspec       = "buildspec-code.yml"
    type            = "CODECOMMIT"
    location        = data.aws_codecommit_repository.repository.clone_url_http
    git_clone_depth = 1
  }

  artifacts {
    artifact_identifier = "code"
    type                = "S3"
    location            = local.artefact_bucket
    path                = "prediction"
    name                = "latest"
    encryption_disabled = true
  }

  secondary_artifacts {
    artifact_identifier = "describers"
    type                = "S3"
    location            = local.artefact_bucket
    path                = "describers"
    name                = "latest"
    encryption_disabled = true
  }

  secondary_artifacts {
    artifact_identifier = "docs"
    type                = "S3"
    location            = local.docs_bucket
    path                = "ell.predictions"
    name                = "latest"
    encryption_disabled = true
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "${data.aws_ecr_repository.codebuild.repository_url}:latest"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.ecr_repository.repository_url
    }

    environment_variable {
      name  = "IMAGE_VERSION"
      value = "latest"
    }

    environment_variable {
      name  = "BASEIMAGE_URI"
      value = data.aws_ecr_repository.baseimage.repository_url
    }
  }
}

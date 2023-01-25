resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.example.arn
        FullRepositoryId = "lucian-lum/terraform"
        BranchName       = "main"
      }
    }
  }


  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = "test-terraform-codebuild"
      }
    }
  }
}

resource "aws_codebuild_project" "test-terraform-codebuild" {
  name          = "test-terraform-codebuild"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"

  }


  source {
    type            = "CODEPIPELINE"
    location        = "docker/buildspec.yaml"
  }

  source_version = "master"

}

resource "aws_codestarconnections_connection" "example" {
  name          = "terraform-connection"
  provider_type = "GitHub"
}


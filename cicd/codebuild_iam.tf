locals {
  codestar_connection_arn = "arn:aws:codeconnections:us-east-1:846229150353:connection/646d1c0b-fdc0-413e-90f4-ae594d6723c6"
}



resource "aws_iam_role" "codebuild_role" {
    name = "codebuild-service-role"

    assume_role_policy = jsonencode({
        Version ="2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Principal = {
                Service = "codebuild.amazonaws.com"
            },
            Action= "sts:AssumeRole"
          }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
    role=aws_iam_role.codebuild_role.name
    policy_arn =  "arn:aws:iam::aws:policy/AdministratorAccess"
  
}

resource "aws_iam_policy" "codepipeline_codebuild_access" {
  name = "CodePipelineCodeBuildAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = "arn:aws:codebuild:us-east-1:846229150353:project/terraform-build-dev"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codebuild_access.arn
}


resource "aws_codebuild_project" "terraform_build" {
    name= "terraform-build-dev"
    description = "build project for terraform deployment"
    build_timeout = 10
    service_role = aws_iam_role.codebuild_role.arn

    artifacts {
      type = "NO_ARTIFACTS"
    }

    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:6.0"
      type ="LINUX_CONTAINER"

      environment_variable {
        name = "TF_ENV"
        value = "dev"
      }
      
      privileged_mode = false
    }

    source {
      type = "GITHUB"
      location = "https://github.com/Snekainus/multi-env-infra.git"
      buildspec = "cicd/buildspec.yml"
    }
  
}

resource "aws_iam_role" "codepipeline_role" {
    name = "codepipeline-service-role"

    assume_role_policy = jsonencode({
        Version="2012-10-17"
        Statement=[
          {
            Effect = "Allow",
            Principal = {
                Service="codepipeline.amazonaws.com"
            },
            Action = "sts:AssumeRole"
          }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  
}

resource "aws_iam_policy" "codestar_use_connection_policy" {
  name = "CodeStarUseConnectionPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "codestar-connections:UseConnection",
        Resource = "arn:aws:codeconnections:us-east-1:846229150353:connection/646d1c0b-fdc0-413e-90f4-ae594d6723c6"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codestar_connection" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_use_connection_policy.arn
}

resource "aws_iam_policy" "codepipeline_s3_access" {
  name = "CodePipelineS3AccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::my-terraform-pipeline-artifacts-dev-xyz2025",
          "arn:aws:s3:::my-terraform-pipeline-artifacts-dev-xyz2025/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_policy_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access.arn
}




resource "aws_codepipeline" "terraform_pipeline" {
    name= "terraform-deploy-dev"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
      location = aws_s3_bucket.codepipeline_artifacts.bucket
      type = "S3"
    }
    stage {
      name="Source"

      action {
        name="Source"
        category = "Source"
        owner="AWS"
        provider = "CodeStarSourceConnection"
        version="1"
        output_artifacts = ["source_output"]

        configuration = {
            ConnectionArn    = local.codestar_connection_arn
            FullRepositoryId = "Snekainus/multi-env-infra"
            BranchName       = "main"
            DetectChanges    = "true"
        }
      }
    }

    stage {
      name= "Build"

      action {
            name="BuildTerraform"
            category="Build"
            owner="AWS"
            provider="CodeBuild"
            input_artifacts=["source_output"]
            output_artifacts=["build_output"]
            version="1"

            configuration = {
                ProjectName=aws_codebuild_project.terraform_build.name
            }
          
        }
        
      }
    }




resource "aws_s3_bucket""codepipeline_artifacts"{
        bucket="my-terraform-pipeline-artifacts-dev-xyz2025"
        force_destroy = true
}

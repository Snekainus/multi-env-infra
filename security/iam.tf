resource "aws_iam_role" "codebuild_role"{
    name="codebuild_role"
    assume_role_policy = jsonencode({
        Version="2012-10-17",
        Statement= [
            {
                Effect="Allow",
                Principal={
                    Service="codebuild.amazonaws.com"
                },
                Action="sts:AssumeRole"
            }]
 } )
  
}
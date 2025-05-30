resource "aws_iam_role" "codepipeline_role" {
    name="codepipeline-service-role"

    assume_role_policy = jsonencode({
        Version="2012-10-17"
        Statement=[{
            Effect="Allow",
            Principal={
                Service="codepipeline.amazonaws.com"
            },
            Action="sts:AssumeRole"
        }]
    })
  
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
    role=aws_iam_role.codepipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
  
}
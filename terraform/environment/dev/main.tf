provider "aws" {
    region = "us-east-1"  
}
module "vpc" {
    source = "../../modules/vpc"
    vpc_cidr="10.0.0.0/16"
    public_subnet_cidrs=["10.0.1.0/24","10.0.2.0/24"]
    availability_zones=["us-east-1a","us-east-1b"]
    env="dev"  
}

resource "aws_security_group" "dev_sg" {
    name="dev-ec2-sg"
    description = "Allow SSh"
    vpc_id = module.vpc.vpc_id  

ingress {
    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks = ["10.0.0.0/16"]
}
egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
}
tags={
    name="dev-ec2-sg"
}
}
module "ec2"{
    source = "../../modules/ec2"
    ami_id="ami-0554aa6767e249943"
    instance_type="t2.micro"
    subnet_id=module.vpc.public_subnets[0]
    security_group_ids=[aws_security_group.dev_sg.id]
    key_name="terraform-env-dev"
    env="dev"
    user_data=file("${path.module}/user_data.sh")
}
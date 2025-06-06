resource "aws_security_group" "web" {
    name="web-sg"
    description = "Allow Http and ssh"
    vpc_id = module.vpc.vpc_id

    ingress  {
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks =["10.0.0.0/16"]
     }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
  
}

resource "aws_vpc""main"{
    cidr_block=var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      name="${var.env}-vpc"
    }

}

resource "aws_subnet" "public" {
    count=length(var.public_subnet_cidrs)
    vpc_id=aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = element(var.availability_zones,count.index)
    map_public_ip_on_launch = true
    tags={
        name="${var.env}-public-subnet-${count.index+1}"
    }
  
}
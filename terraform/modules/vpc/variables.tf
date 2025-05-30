variable "vpc_cidr" {}
variable "public_subnet_cidrs"{
    type = list(string)  
}
variable "availability_zones"{
    type= list(string)
}
variable "env" { 
}
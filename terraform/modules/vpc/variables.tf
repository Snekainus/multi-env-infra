variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "public_subnet_cidrs"{
    description = "List of public subnet CIDRs"
    type = list(string)  
}
variable "availability_zones"{
    description = "List of availability zones"
    type= list(string)
}
variable "env" { 
  description = "Deployment environment (e.g., dev, qa, prod)"
  type        = string
}
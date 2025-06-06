variable "ami_id" {
    description = "AMI id used for this instance"
    type = string  
}
variable "instance_type" {
    description = "the type of the instance"
    type = string
  
}
variable "subnet_id" {
    description = "Subnetid where the instance will be launched"
    type = string
  
}
variable "security_group_ids" {
    description = "EC2 instance security group ids"
    type = list(string)
  
}
variable "key_name" {
    description = "EC2 key pair name"
    type = string
  
}
variable "env" {
    description = "Environment name(dev,qa,prod)"
    type = string
  
}
variable "user_data" {
    description = "user data script to run to launch the instance"
    type = string
    default = " "
  
}
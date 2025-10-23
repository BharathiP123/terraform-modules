variable "ami" {
    type = string
    description = " provide the ami id based the reqest"
  
}

variable "instance_type" {
    type = string
    description = "provide the instance type"
  
}

variable "sg_ids" {
    type = list
    description = "provide the security group id"
  
}

variable "tags" {
    type = map
    default = {}
  
}
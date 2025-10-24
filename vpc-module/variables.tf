variable "vpc_cidr" {
    type = string
    description = "provide the vpc cidr"
  
}

variable "project" {
  type = string
  description = "provide the project name"

}
variable "environment" {
    type = string
    description = "provide the project name"
  
}

variable "vpc_tags" {
    type = map
    default = {}

}

variable "ig_tags" {
    type = map
    default = {}
  
}

variable "public_cidrs" {
    type = list
  
}

variable "public_tags" {
    type = map
    default = {}
}

variable "database_cidrs" {
    type = list
  
}

variable "database_tags" {
    type = map
    default = {}
}

variable "private_cidrs" {
    type = list
  
}

variable "private_tags" {
    type = map
    default = {}
}

variable "public_routetable_tags" {
    type = map
    default = {}
}


variable "private_routetable_tags" {
    type = map
    default = {}
}


variable "database_routetable_tags" {
    type = map
    default = {}
}

variable "eip_tags"{
    type = map
    default = {}
}

variable "nat_tags"{
    type = map
    default = {}
}

variable "peering" {
    type = string
    default = "true"
      
}
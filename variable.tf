

  variable "Project"{
    type = string
  }

  variable "Environment"{
    type = string
  }

  variable "cidr_block"{
    type = string
    default = "10.0.0.0/16"
  }
  
  variable "vpc_tags"{
    type = map 
    default ={}
  }
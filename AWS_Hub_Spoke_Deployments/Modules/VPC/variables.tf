variable "name" {}
variable "cidr" {}
variable "azs" { type = list(string) }

variable "private_subnets" { type = list(string) }
variable "tgw_subnets"     { type = list(string) }



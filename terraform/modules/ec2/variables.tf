variable "instance-type" {
  type        = string
  description = "the type of instance "
}

variable "my_key" {
  type = string
  description = "the ec2 key pair name"
}

variable "subnet-id" {
  type        = string
  description = "the subnet id "
}

variable "security-group-id" {
  type        = string
  description = "the security group id "
}
variable "isPublic" {
  type = string
  description = "is the ec2 public or not "
}
variable "tags" {
  type    = map(string)
  default = {}
}

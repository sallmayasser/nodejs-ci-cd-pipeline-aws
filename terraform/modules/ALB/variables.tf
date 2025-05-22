variable "alb-name" {
  type        = string
  description = "value of AlB name"
}

variable "isInternal" {
  type = bool
}

variable "security-group-ids" {
  type        = list(string)
  description = "the list of security group id to attach to the ALB"
}

variable "subnet-ids" {
  type        = list(string)
  description = "the list of subnets id to attach to the ALB"
}

variable "target-gp-name" {
  type        = string
  description = "the name of target group"
}

variable "vpc-id" {
  type        = string
  description = "the id of Vpc"
}

variable "target-group-list-id" {
  type        = map(string)
  description = "the list of target group ids"

}

variable "subnet-ids" {
  type        = list(string)
  description = "the list of subnets id to attach to the RDS"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true

}

variable "sg-id-list" {
  type        = list(string)
  description = "the list of db security group id that attached with db"
}
variable "redis-name" {
  type        = string
  description = "the redis instance name "
}

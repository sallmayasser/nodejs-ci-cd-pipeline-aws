output "bastion-ip" {
  description = "the Bastion host instance ip "
  value       = module.Bastion-host.public_ip
}

output "slave-ip" {
  description = "the jenkins slave instance ip "
  value       = module.jenkins-slave.private_ip
}

output "node1-ip" {
  description = "the node app instance 1 ip "
  value       = module.node-app-1.private_ip
}

output "node2-ip" {
  description = "the node app instance 2 ip "
  value       = module.node-app-2.private_ip
}

output "app-dns" {
  description = "the application dns name"
  value       = "http://${module.my-alb.alb-dns}"
}

output "mysql-endpoint" {
  description = "the mysql endpoint"
  value = module.databases.sql-endpoint
  
}
output "redis-endpoint" {
  description = "the redis db endpoint"
  value = module.databases.redis-endpoint
  
}
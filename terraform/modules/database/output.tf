output "sql-endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "the my sqldb endpoint "
}
output "redis-endpoint" {
  value       = aws_elasticache_serverless_cache.redis.endpoint
  description = "the my redis endpoint "
}

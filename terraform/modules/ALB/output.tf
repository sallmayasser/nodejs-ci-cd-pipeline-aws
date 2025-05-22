output "alb-dns" {
  value       = aws_lb.my-ALB.dns_name
  description = "the dns of the ALB "
}

output "private_alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.private_alb.dns_name
}
output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb_sg.id
}

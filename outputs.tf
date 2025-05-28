output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.vpc.id
}

output "instance_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.web_instance.public_ip
}

output "load_balancer_dns" {
  description = "DNS público del Load Balancer"
  value       = aws_lb.loadbalancer.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID del Load Balancer"
  value       = aws_lb.loadbalancer.zone_id
}

output "domain_name" {
  description = "Dominio configurado en Route 53"
  value       = var.domain_name
}

output "route53_zone_id" {
  description = "Zone ID de Route 53"
  value       = aws_route53_zone.main_zone.zone_id
}

output "route53_name_servers" {
  description = "Name servers para configurar en tu registrar de dominios"
  value       = aws_route53_zone.main_zone.name_servers
}

output "api_endpoint" {
  description = "URL completa de la API"
  value       = "http://${var.domain_name}"
}

output "direct_ec2_access" {
  description = "URL directa a la instancia EC2 (para debugging)"
  value       = "http://${aws_instance.web_instance.public_ip}"
}

output "ssh_command" {
  description = "Comando SSH para conectar a la instancia"
  value       = "ssh -i tfg-key.pem ec2-user@${aws_instance.web_instance.public_ip}"
}

output "alb_dns" {
  value = aws_lb.loadbalancer.dns_name
}

output "domain_url" {
  value = "http://${var.domain_name}"
}
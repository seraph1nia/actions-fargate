output "public_ip" {
  value = aws_lb.main.dns_name
}

output "image_used" {
  value = var.image
}
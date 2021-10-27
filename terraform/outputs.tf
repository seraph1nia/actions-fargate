output "public_ip" {
    value = aws_lb.main.dns_name
}
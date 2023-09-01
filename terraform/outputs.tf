output "aws_route53_zone_id" {
  value = aws_route53_zone.etrbd_zone.zone_id
}

output "aws_acm_certificate_arn" {
  value = aws_acm_certificate.etrbd_cert.arn
}

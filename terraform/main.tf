provider "aws" {
    region = var.aws_region

    default_tags {
        tags = {
            Environment = "Production"
            Owner       = "Rayman Jamal"
            Project     = "Elect The Ring Bearer"
            ManagedBy   = "Terraform"
        }
    }
}

locals {
  validation_options = tolist(aws_acm_certificate.etrbd_cert.domain_validation_options)
}

resource "aws_s3_bucket" "etrl_bucket" {
  bucket = "electtheringbearer"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "etrl_bucket_ownership_controls" {
  bucket = aws_s3_bucket.etrl_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "etrl_bucket_public_access_block" {
  bucket = aws_s3_bucket.etrl_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "etrl_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.etrl_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.etrl_bucket_public_access_block,
  ]
  bucket = aws_s3_bucket.etrl_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "etrl_bucket_website_configuration" {
  bucket = aws_s3_bucket.etrl_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for electtheringbearer.com"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.etrl_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.etrbd_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_zone" "etrbd_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "etrbd_a_record" {
  zone_id = aws_route53_zone.etrbd_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "etrbd_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "etrbd_cert_validation" {
  zone_id = aws_route53_zone.etrbd_zone.zone_id
  name    = local.validation_options[0].resource_record_name
  type    = local.validation_options[0].resource_record_type
  records = [local.validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "etrbd_cert_validation" {
  certificate_arn         = aws_acm_certificate.etrbd_cert.arn
  validation_record_fqdns = [aws_route53_record.etrbd_cert_validation.fqdn]
}

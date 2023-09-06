provider "aws" {
    region = var.aws_region

    default_tags {
        tags = var.default_tags
    }
}

locals{
    domain_name = "${var.stack_name}.com"
    origin_id = "S3Origin"
    logging_bucket = "etrb-logging-bucket"
}

resource "aws_cloudfront_origin_access_control" "etrb_oac" {
  name                              = "etrb-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket" "etrb_bucket" {
  bucket = var.stack_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.etrb_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront  .json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.etrb_distribution.arn
      ]
    }

    resources = [
      aws_s3_bucket.etrb_bucket.arn,
      "${aws_s3_bucket.etrb_bucket.arn}/*",
    ]
  }
}

# resource "aws_s3_bucket_policy" "etrb_bucket_policy"{
#   bucket = aws_s3_bucket.etrb_bucket.id
  
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "AllowCloudFrontLogging",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "cloudfront.amazonaws.com"
#       },
#       "Action": "s3:PutObject",
#       "Resource": "arn:aws:s3:::${var.stack_name}/*",
#       "Condition": {
#         "StringEquals": {
#           "s3:x-amz-acl": "bucket-owner-full-control"
#         }
#       }
#     }
#   ]
# }
# EOF
# }

resource "aws_cloudfront_distribution" "etrb_distribution" {
    origin {
    domain_name              = aws_s3_bucket.etrb_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.etrb_oac.id
    origin_id                = local.origin_id
  }

  enabled = true
  is_ipv6_enabled = true

  # logging_config {
  #   bucket = aws_s3_bucket.etrb_bucket.bucket_domain_name
  #   prefix = "cloudfront-logs"
  # }

  # aliases = ["${local.domain_name}"]

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.origin_id 
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}
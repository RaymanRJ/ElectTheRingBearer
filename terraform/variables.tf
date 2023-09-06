variable "aws_region" {
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Name of the stack"
  default     = "electtheringbearer"
}

variable "default_tags" {
  description = "Default tags for AWS resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Owner       = "Rayman Jamal"
    Project     = "Elect The Ring Bearer"
    ManagedBy   = "Terraform"
  }
}
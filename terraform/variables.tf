variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "key_name" {
  type        = string
  description = "EC2 Key pair"
  default     = "aws-server2"
}


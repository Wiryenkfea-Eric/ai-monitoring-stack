variable "aws_region" {
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging"
  default     = "ai-monitoring-stack"
}

variable "your_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "key_pair_name" {
  description = "Name of your AWS EC2 key pair"
  type        = string
}

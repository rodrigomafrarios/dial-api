variable "region" {
  description = "The region to deploy the infrastructure to"
  type        = string
}

variable "tags" {
  description = "The tags to apply to all taggable resources"
  type        = map(string)
}

variable "env" {
  type        = string
  description = "Deployment environment i.e. dev, qa, prod"
}

variable "name" {
  description = "project name"
  type        = string
}

variable "account_id" {
  type = string
}

variable "app_name" { type = string }
variable "aws_region" { type = string, default = "ap-south-1" }
variable "tfstate_bucket" { type = string }
variable "tfstate_dynamodb_table" { type = string, default = "" }

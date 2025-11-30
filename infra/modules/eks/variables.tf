variable "app_name" { type = string }
variable "k8s_version" { type = string, default = "1.26" }
variable "map_roles" { type = map(any), default = {} }

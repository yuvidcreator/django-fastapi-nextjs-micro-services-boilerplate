variable "app_name" { type = string }
variable "github_repo" { type = string } # e.g. myorg/myrepo
variable "github_branch" { type = string, default = "staging" } # limit trust to branch/environment

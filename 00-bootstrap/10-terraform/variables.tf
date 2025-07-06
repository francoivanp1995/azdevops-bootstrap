variable "azure_devops_pat" {
  type      = string
  sensitive = true
}

variable "org_service_url" {
  type = string
  description = "url of the devops organization"
}

variable "projects" {
  type = list(string)
}
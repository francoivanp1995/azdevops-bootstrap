resource "azuredevops_project" "this" {
  for_each           = toset(var.projects)
  name               = each.key
  description        = "Project created by Terraform: ${each.key}"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}
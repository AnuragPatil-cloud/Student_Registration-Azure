resource "azurerm_resource_group" "student_registration" {
  name     = "Student-Registration-Azure-RG"
  location = var.location

  tags = {
    project     = "Student-Registration"
    environment = "lab"
    managed_by  = "terraform"
  }
}

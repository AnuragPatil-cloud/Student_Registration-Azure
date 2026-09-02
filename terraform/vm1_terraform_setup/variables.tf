variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "South India"
}

variable "admin_username" {
  description = "Linux administrator username"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2as_v2"
}

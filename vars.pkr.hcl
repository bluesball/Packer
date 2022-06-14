variable "proxmox_api_url" {
  type        = string
  description = "Proxmox URL"
  default     = "https://url-do-proxmox:8006/api2/json"
}
variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox Token ID"
  default     = "root@pam!seuid" 
}
#variable "px_pass" {
#  type        = string
#  description = "Proxmox User Password"
#  default     = "automate"
#}
variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API Token"
  default     = "o token vai aqui"
  sensitive = true
}
variable "px_vmname" {
  type        = string
  description = "Proxmox VM Name"
  default     = "template-ubuntu-2204"
}
variable "ssh_user" {
  type        = string
  description = "SSH User"
  default     = "ubuntu"
}
variable "ssh_pass" {
  type        = string
  description = "SSH Password"
  default     = "ubuntu"
}
variable "ip_add" {
  type        = string
  description = "VM IP Address"
  default     = "ip do template que vai ser setado no boot command"
}
variable "ip_mask" {
  type        = string
  description = "VM IP Mask"
  default     = "255.255.255.0"
}
variable "ip_gateway" {
  type        = string
  description = "VM IP Gateway"
  default     = "ip do gateway"
}
variable "ip_dns" {
  type        = string
  description = "VM DNS IP"
  default     = "8.8.8.8"
}

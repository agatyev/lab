variable "endpoint" {
  description = "Proxmox API endpoint, for example https://10.0.0.2:8006"
  type        = string
}

variable "api_token" {
  description = "Proxmox API token as user@realm!tokenid=secret"
  type        = string
  sensitive   = true
}

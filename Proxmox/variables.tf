
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
}

variable "win2022_vms" {
    type = map(object({
        name = string
        desc = string
        vmid = number
        disk_size = optional(string)
        clone = optional(string)
    }))
}

variable "rl_vms" {
    type = map(object({
        name = string
        desc = string
        vmid = number
        disk_size = optional(string)
        clone = optional(string)
    }))
}

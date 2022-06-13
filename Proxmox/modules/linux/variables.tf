
variable "random_num" {
    type = number
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

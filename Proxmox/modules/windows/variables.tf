
variable "random_num" {
    type = number
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

# Example local module variables
locals {
    vms = {
        # Name = Desc
        "win2022-1" = {
            desc = "Terraform Win2022-1 VM"
            vmid = 100
        }
    }
}

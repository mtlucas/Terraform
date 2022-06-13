
variable "win_build_agent_vm_start_num" {
    type    = number
    default = 10
}

variable "win_build_agent_vm_end_num" {
    type    = number
    default = 65
}

variable "win_build_agent_vm_upgrade_slider_num" {
    type    = number
}

variable "win_build_agent_vm_template_current" {
    type    = string
}

variable "win_build_agent_vm_template_previous" {
    type    = string
}

#variable "win_build_agent_vm_template_upgrade_map" {
#    type = map(string = boolean)
#}

locals {
    win_build_agent_vm_template_upgrade_map = {
        for i in range(var.win_build_agent_vm_start_num, var.win_build_agent_vm_end_num + 1) : format("TCBUILD%02d", i) =>
            (i <= var.win_build_agent_vm_upgrade_slider_num ? true : false)
    }
}

output "win_build_agent_vm_template_upgrade_map" {
  value = local.win_build_agent_vm_template_upgrade_map
}

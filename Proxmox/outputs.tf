
output "Windows_default_ipv4_addresses" {
    value = module.Windows.default_ipv4_address
    #sensitive = true
}

output "Linux_default_ipv4_addresses" {
    value = module.Linux.default_ipv4_address
    #sensitive = true
}

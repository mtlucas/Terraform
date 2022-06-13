# Proxmox Provider
# ---
# Initial Provider Configuration for Proxmox

provider "proxmox" {

    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret

    # (Optional) Skip TLS Verification
    pm_tls_insecure = true

    # Uncomment the below for debugging.
    pm_log_enable = true
    pm_log_file = "terraform-plugin-proxmox.log"
    #pm_debug = true
    pm_log_levels = {
    _default = "debug"
    _capturelog = ""
    }
}

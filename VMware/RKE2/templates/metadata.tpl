instance-id: ${hostname}
local-hostname: ${hostname}
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - ${ip_address}
      gateway4: ${gateway}
      nameservers:
        addresses:
%{ for ns in nameservers ~}
          - ${ns}
%{ endfor ~}
        search:
          - ${domain}
#cloud-config
hostname: ${hostname}
users:
  - name: ${username}
    groups: wheel,sudo
    passwd: ${password}
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
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
runcmd:
  - printf '#!/bin/bash\nalias l="ls -la"\n' > /root/.bashrc
  - echo 'H4sIAAAAAAAAA3VQuw7DMAjc/RVsaaWG/Eg/AdXZoi7x0vE+vuZhk6FFlnUccJx4tuN4nwe1kz6NmQvVSh4Oxq8R9GjIQmU2toNJEdcMLiCCTeDyNhqUQZmyUSBAWWtGbAMu6/FTt3+PtcdiQq8U1s6bVnZFMpph5vfOa2L1f7qY/rYqKSzDfa8z7ekXc7FZ1R0rO1iiy7ktDmc6rNQ9DOusUFqN+7tk3BckDuyMAT2zXGh0GoWYAKVA0KWUL6jAVQoUAgAA' | base64 -d | gunzip > /etc/motd

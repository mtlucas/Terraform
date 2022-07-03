# This script is used to import Environment variables into Terraform using Powershell
ConvertTo-Json @{
    USERPROFILE = $Env:USERPROFILE
  }

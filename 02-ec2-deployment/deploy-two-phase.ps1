param(
  [string]$TfVarsFile = "dev.tfvars"
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

function Invoke-Terraform {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Args
  )

  & terraform @Args
  if ($LASTEXITCODE -ne 0) {
    throw "Terraform command failed: terraform $($Args -join ' ')"
  }
}

$tfVarsPath = if ([System.IO.Path]::IsPathRooted($TfVarsFile)) {
  $TfVarsFile
} else {
  Join-Path $PSScriptRoot $TfVarsFile
}

if (-not (Test-Path $tfVarsPath)) {
  throw "Variables file does not exist: $tfVarsPath"
}

Write-Host "[1/4] Terraform init"
Invoke-Terraform -Args @("init")

Write-Host "[2/4] First apply (temporary CORS='*')"
Invoke-Terraform -Args @("apply", "-auto-approve", "-var-file=$tfVarsPath", "-var", "frontend_public_origin=*")

Write-Host "[3/4] Read frontend public IP"
$frontendIp = (& terraform output -raw frontend_public_ip)
if ($LASTEXITCODE -ne 0) {
  throw "Cannot read output frontend_public_ip."
}

$frontendIp = $frontendIp.Trim()
if ([string]::IsNullOrWhiteSpace($frontendIp)) {
  throw "Cannot read frontend_public_ip output."
}

$frontendOrigin = "http://$frontendIp"
Write-Host "Detected frontend origin: $frontendOrigin"

Write-Host "[4/4] Second apply (final CORS origin)"
Invoke-Terraform -Args @("apply", "-auto-approve", "-var-file=$tfVarsPath", "-var", "frontend_public_origin=$frontendOrigin")

Write-Host "Done."
Write-Host "Frontend URL: $frontendOrigin"
Write-Host "Backend via proxy: $frontendOrigin/chat"

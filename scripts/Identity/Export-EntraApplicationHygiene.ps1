#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Applications

<#
.SYNOPSIS
    Exports a read-only Entra application hygiene inventory.

.DESCRIPTION
    Collects application registrations and service principals, then records
    ownership, credential expiry, and assigned application permissions. This
    script never changes tenant state.

.NOTES
    Required delegated Graph permissions:
    Application.Read.All
    Directory.Read.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F-]{36}$|^[a-zA-Z0-9-]+\.onmicrosoft\.com$')]
    [string]$TenantId,

    [ValidateRange(1, 3650)]
    [int]$ExpiryWarningDays = 90,

    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = (Join-Path $PSScriptRoot '../../output')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($TenantId -match '^(?i:contoso\.onmicrosoft\.com|your_|replace_|<.+>)$') {
    throw 'TenantId contains a placeholder. Supply a real tenant ID or domain at run time.'
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportPath = Join-Path $OutputPath "EntraApplicationHygiene-$timestamp.csv"

Connect-MgGraph -TenantId $TenantId -Scopes 'Application.Read.All', 'Directory.Read.All' -NoWelcome

try {
    $now = Get-Date
    $warningDate = $now.AddDays($ExpiryWarningDays)
    $applications = Get-MgApplication -All -Property 'id,appId,displayName,passwordCredentials,keyCredentials'
    $servicePrincipals = Get-MgServicePrincipal -All -Property 'id,appId,displayName,accountEnabled,appRoleAssignments'

    $servicePrincipalsByAppId = @{}
    foreach ($servicePrincipal in $servicePrincipals) {
        if ($servicePrincipal.AppId) {
            $servicePrincipalsByAppId[$servicePrincipal.AppId] = $servicePrincipal
        }
    }

    $report = foreach ($application in $applications) {
        $owners = Get-MgApplicationOwner -ApplicationId $application.Id -All -ErrorAction SilentlyContinue
        $credentials = @($application.PasswordCredentials) + @($application.KeyCredentials)
        $nextExpiry = $credentials |
            Where-Object EndDateTime |
            Sort-Object EndDateTime |
            Select-Object -First 1 -ExpandProperty EndDateTime
        $servicePrincipal = $servicePrincipalsByAppId[$application.AppId]

        [pscustomobject]@{
            DisplayName             = $application.DisplayName
            ApplicationId           = $application.AppId
            HasServicePrincipal     = [bool]$servicePrincipal
            ServicePrincipalEnabled = if ($servicePrincipal) { $servicePrincipal.AccountEnabled } else { $null }
            OwnerCount              = @($owners).Count
            CredentialCount         = @($credentials).Count
            NextCredentialExpiry    = $nextExpiry
            ExpiringWithinWarning   = [bool]($nextExpiry -and $nextExpiry -le $warningDate)
        }
    }

    $report |
        Sort-Object -Property @{ Expression = 'ExpiringWithinWarning'; Descending = $true }, OwnerCount |
        Export-Csv -Path $reportPath -NoTypeInformation
    Write-Information "Read-only report created: $reportPath" -InformationAction Continue
}
finally {
    Disconnect-MgGraph | Out-Null
}

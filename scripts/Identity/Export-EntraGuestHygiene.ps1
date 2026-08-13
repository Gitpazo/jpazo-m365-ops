#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users

<#
.SYNOPSIS
    Exports a read-only inventory of Entra guest accounts for review.

.DESCRIPTION
    Classifies guests using invitation state, account status, and creation age.
    It does not remove or modify accounts. Use the output as an evidence source
    for a separate, approved access-lifecycle process.

.NOTES
    Required delegated Graph permissions:
    User.Read.All
    Directory.Read.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F-]{36}$|^[a-zA-Z0-9-]+\.onmicrosoft\.com$')]
    [string]$TenantId,

    [ValidateRange(1, 3650)]
    [int]$PendingInvitationDays = 90,

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
$reportPath = Join-Path $OutputPath "EntraGuestHygiene-$timestamp.csv"

Connect-MgGraph -TenantId $TenantId -Scopes 'User.Read.All', 'Directory.Read.All' -NoWelcome

try {
    $threshold = (Get-Date).AddDays(-$PendingInvitationDays)
    $guests = Get-MgUser -All -Filter "userType eq 'Guest'" -Property 'id,displayName,userPrincipalName,accountEnabled,createdDateTime,externalUserState,externalUserStateChangeDateTime'

    $report = foreach ($guest in $guests) {
        $stateChanged = $guest.ExternalUserStateChangeDateTime
        $isPendingAndOld = $guest.ExternalUserState -eq 'PendingAcceptance' -and $stateChanged -and $stateChanged -lt $threshold
        $classification = if (-not $guest.AccountEnabled) {
            'ReviewDisabled'
        }
        elseif ($isPendingAndOld) {
            'ReviewPendingInvitation'
        }
        elseif ($guest.ExternalUserState -eq 'Accepted') {
            'Accepted'
        }
        else {
            'ReviewUnknownState'
        }

        [pscustomobject]@{
            DisplayName                    = $guest.DisplayName
            UserPrincipalName              = $guest.UserPrincipalName
            AccountEnabled                 = $guest.AccountEnabled
            CreatedDateTime                = $guest.CreatedDateTime
            ExternalUserState              = $guest.ExternalUserState
            ExternalUserStateChangeDateTime = $stateChanged
            Classification                 = $classification
        }
    }

    $report | Sort-Object Classification, ExternalUserStateChangeDateTime | Export-Csv -Path $reportPath -NoTypeInformation
    Write-Information "Read-only report created: $reportPath" -InformationAction Continue
}
finally {
    Disconnect-MgGraph | Out-Null
}

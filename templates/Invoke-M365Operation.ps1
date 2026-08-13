#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    Public-safe template for an idempotent Microsoft 365 operation.

.DESCRIPTION
    Starts in Audit mode and accepts all tenant and target context as parameters.
    Implement Get-CurrentState and Set-DesiredState for one narrowly defined
    operation. Never add tenant-specific defaults, passwords, client secrets,
    certificates, or production identifiers to this file.

.NOTES
    Required Microsoft Graph permissions: document the least-privilege scopes
    required by your implementation here.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F-]{36}$|^[a-zA-Z0-9-]+\.onmicrosoft\.com$')]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetId,

    [ValidateSet('Audit', 'Apply')]
    [string]$Mode = 'Audit',

    [switch]$ConfirmApply,

    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = (Join-Path $PSScriptRoot '../output')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-PublicSafeInput {
    param([string]$Value, [string]$Name)

    if ($Value -match '^(?i:your_|replace_|<.+>|changeme|todo|contoso\.onmicrosoft\.com|example-target)$') {
        throw "$Name contains a placeholder. Supply a real value at run time."
    }
}

function Write-AuditLog {
    param([string]$Message, [ValidateSet('Info', 'Warning', 'Error')] [string]$Level = 'Info')

    $line = '[{0:u}] [{1}] {2}' -f (Get-Date), $Level, $Message
    Add-Content -Path $script:LogPath -Value $line
    Write-Information $line -InformationAction Continue
}

function Get-CurrentState {
    param([string]$Target)

    # TODO: Query the target's current state. Return a small object with an
    # IsCompliant Boolean and only non-sensitive values needed for a decision.
    throw 'Implement Get-CurrentState before using this template.'
}

function Set-DesiredState {
    param([string]$Target)

    # TODO: Make the smallest necessary change. This function is called only
    # after Get-CurrentState reports that the desired state is not present.
    throw 'Implement Set-DesiredState before using this template.'
}

Assert-PublicSafeInput -Value $TenantId -Name 'TenantId'
Assert-PublicSafeInput -Value $TargetId -Name 'TargetId'

if ($Mode -eq 'Apply' -and -not $ConfirmApply) {
    throw 'Apply mode requires -ConfirmApply. Start with Audit mode or -WhatIf.'
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
$script:LogPath = Join-Path $OutputPath ('operation-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))

Write-AuditLog -Message 'Starting operation. Authentication uses interactive Microsoft Graph sign-in.'
Connect-MgGraph -TenantId $TenantId -NoWelcome

try {
    $state = Get-CurrentState -Target $TargetId

    if ($state.IsCompliant) {
        Write-AuditLog -Message 'No change required. Target already matches the desired state.'
        return
    }

    if ($Mode -eq 'Audit') {
        Write-AuditLog -Level Warning -Message 'Change required. Audit mode made no changes.'
        return
    }

    if ($PSCmdlet.ShouldProcess($TargetId, 'Apply desired state')) {
        Set-DesiredState -Target $TargetId
        Write-AuditLog -Message 'Desired state applied.'
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}

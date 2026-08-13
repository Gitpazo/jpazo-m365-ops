BeforeAll {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
    $ScriptFiles = Get-ChildItem -Path $RepositoryRoot -Recurse -Filter '*.ps1' -File |
        Where-Object { $_.FullName -notmatch '[/\\]tests[/\\]' }

    $DisallowedLiterals = @(
        '$ClientSecret =',
        '$Password =',
        'AZURE_CLIENT_SECRET=',
        '-----BEGIN PRIVATE KEY-----',
        '-----BEGIN CERTIFICATE-----'
    )
}

Describe 'Public safety guardrails' {
    It 'does not contain common hardcoded credential literals' {
        foreach ($ScriptFile in $ScriptFiles) {
            $Content = Get-Content -Path $ScriptFile.FullName -Raw
            foreach ($Literal in $DisallowedLiterals) {
                $Content.Contains($Literal) | Should -BeFalse -Because "Potential credential literal in $($ScriptFile.FullName)"
            }
        }
    }

    It 'uses ShouldProcess in every mutating template' {
        $Template = Join-Path $RepositoryRoot 'templates/Invoke-M365Operation.ps1'
        $Content = Get-Content -Path $Template -Raw

        $Content | Should -Match 'SupportsShouldProcess'
        $Content | Should -Match 'ShouldProcess\('
        $Content | Should -Match 'ConfirmApply'
    }
}

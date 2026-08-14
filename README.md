# jpazo-m365-ops

Reusable, security-first PowerShell tools and operational patterns for Microsoft
365, Entra ID, Intune, Purview, Defender, and SharePoint.

This repository is for generic, public-safe automation only. It does not accept
client data, tenant-specific exports, credentials, certificates, screenshots,
or production configuration files.

## Principles

- Safe by default: scripts start in audit mode and never make changes unless
  explicitly asked.
- Idempotent: an apply operation checks the current state first and makes a
  change only when the desired state is not already present.
- Parameter driven: tenant, target, authentication, and output settings are
  supplied when a script runs. They are never embedded in code.
- Secret free: use interactive sign-in, managed identity, or certificates held
  outside this repository. Never use passwords or client secrets.
- Reviewable: write redacted audit logs and support `-WhatIf` for changes.

## Getting started

1. Read [SECURITY.md](SECURITY.md) and [CONTRIBUTING.md](CONTRIBUTING.md).
2. Copy `templates/Invoke-M365Operation.ps1` to a new script folder.
3. Replace only the clearly marked implementation functions.
4. Add Pester tests, including an idempotency test and a `-WhatIf` test.
5. Run the public-safety checks before opening a pull request.

```powershell
./templates/Invoke-M365Operation.ps1 -TenantId "contoso.onmicrosoft.com" -TargetId "example-target" -Mode Audit
```

`contoso.onmicrosoft.com` and `example-target` are placeholders. Supply your
own values interactively or through your secure automation environment.

## Repository layout

```text
templates/    Starting points for public-safe scripts
scripts/      Read-only reusable operations tools
tests/        Pester checks for public safety and script behaviour
docs/         Design notes and publication checklists
labs/         Safe, fictional proof-of-concept work before publication
```

## Available scripts

- [Export-EntraApplicationHygiene.ps1](scripts/Identity/Export-EntraApplicationHygiene.ps1):
  read-only inventory of Entra application registrations, service principals,
  owners, and credential expiry.
- [Export-EntraGuestHygiene.ps1](scripts/Identity/Export-EntraGuestHygiene.ps1):
  read-only guest inventory and review classification. It does not delete,
  disable, or modify guest accounts.

## Working method

Read [the working method](docs/WORKFLOW.md) before adding a new tool. It uses
five stages: explore, prototype, harden, validate, and publish. The GitHub
workflow validates PowerShell parsing, PSScriptAnalyzer errors, and Pester
tests on pull requests and changes to `main`.

## License

This repository is available under the [MIT License](LICENSE).

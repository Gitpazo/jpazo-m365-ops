# Security policy

## Scope

This repository contains public automation examples. Do not report client
incidents, production tenant details, credentials, or sensitive logs in public
issues, discussions, pull requests, or commits.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting feature if it is enabled for this
repository. Otherwise, contact the repository owner privately through GitHub.

Include a concise description, the affected file and version, reproduction
steps that do not expose data, and the potential impact. Do not publish an
exploit or secret while an issue is being assessed.

## Security requirements for contributions

- Never commit passwords, client secrets, access tokens, private keys,
  certificate files, connection strings, or exported production data.
- Never embed real tenant IDs, domains, emails, app IDs, object IDs, device
  names, group names, URLs, or customer details.
- Require identity and target context as parameters, and reject obvious sample
  placeholder values before a change operation begins.
- Use `SupportsShouldProcess`, `-WhatIf`, and an explicit apply confirmation
  for scripts that can modify state.
- Use least-privilege Microsoft Graph or service permissions and document them
  in each script.
- Redact identifiers and authentication material from logs and examples.

## Supported authentication patterns

- Interactive Microsoft Graph sign-in for local, user-operated scripts.
- Managed identity for Azure-hosted automation.
- Certificate-based authentication when the certificate remains outside the
  repository and the thumbprint is supplied at run time.

Client secrets and passwords are not supported authentication patterns in this
repository.

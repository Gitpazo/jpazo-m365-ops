# Public publication checklist

Run this checklist before publishing any new script or example.

## Content

- [ ] The script was written from a generic requirement, not copied from a client repository.
- [ ] No organisation, person, tenant, domain, app ID, object ID, device, group,
      URL, local path, export, or screenshot identifies a real environment.
- [ ] Every example uses fictional values.
- [ ] No secret, token, certificate, connection string, or authentication export
      is included.

## Behaviour

- [ ] Audit or export is the default mode.
- [ ] Every change checks the current state first.
- [ ] A second run makes no further change when the target is already compliant.
- [ ] Mutating operations support `-WhatIf` and require explicit confirmation.
- [ ] Required permissions are documented and use least privilege.
- [ ] Logs are useful but redact sensitive input and output.

## Validation

- [ ] Run `Invoke-Pester ./tests`.
- [ ] Run a syntax check with PowerShell 7.
- [ ] Review the full staged diff, including deleted and renamed files.
- [ ] Run a secret scanner before pushing.

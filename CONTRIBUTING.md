# Contributing

Thank you for helping make Microsoft 365 automation safer and easier to reuse.

## Before opening a pull request

1. Start from a generic use case, not from a client script.
2. Remove all tenant-specific values, identifiers, exports, paths, and comments.
3. Use mandatory parameters for target and authentication context.
4. Make audit or export mode the default.
5. For any mutation, implement `SupportsShouldProcess`, `-WhatIf`, and a
   separate confirmation switch.
6. Add a pre-change state check so repeated runs converge without duplicate or
   unnecessary changes.
7. Add Pester tests for parameter validation, audit mode, `-WhatIf`, and
   idempotency.
8. Run `Invoke-Pester ./tests` and review every changed line before publishing.

## Public-safe examples

Use fictional values such as:

```text
contoso.onmicrosoft.com
00000000-0000-0000-0000-000000000000
example-target
C:\Temp\output
```

Do not use a real organisation's data, even if it appears harmless.

## Pull request expectations

Explain the problem, the safe default behaviour, permissions required, how the
script avoids repeated changes, and the tests you ran. Keep each pull request
focused on one reusable capability.

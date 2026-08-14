# Working method

This repository turns useful Microsoft 365 operations into public-safe tools.
It does not turn production scripts into public code unchanged.

## 1. Explore

Start with a read-only question and a fictional example. Record the problem,
the Microsoft service involved, the minimum permissions required, and the
evidence needed for a decision.

Place notes, links, and non-sensitive diagrams in `docs/`. Do not add tenant
exports, screenshots, customer names, or policy exports.

## 2. Prototype

Build a small proof of concept in `labs/`. A lab is deliberately not a public
script. It may be incomplete, but it must still contain no credentials or real
tenant data.

Promote a lab to `scripts/` only when its input, output, failure modes, and
permissions are understood.

## 3. Harden

Before publishing a script, make its safe behaviour explicit:

- Require tenant and target context at run time.
- Default to read-only audit or export behaviour.
- Use `SupportsShouldProcess`, `-WhatIf`, and an explicit confirmation switch
  for every mutating operation.
- Check the current state before a change so repeated runs converge.
- Write reports outside the repository.

## 4. Validate

Each change needs Pester coverage for public safety and script behaviour. Run
the checks locally and let the GitHub workflow repeat them on a pull request.

## 5. Publish and learn

Use one pull request for one capability. Explain the use case, permissions,
safe default, limitations, and validation. A public release should teach a
reader how to make a safe decision, not only how to run a command.

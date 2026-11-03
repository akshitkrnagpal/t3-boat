# Security

This skill tells an agent how to handle GitHub, Claude, Tailscale, and T3
credentials on a VM. A step that could print, copy, or persist a secret where
it should not is a security issue.

## Reporting

Report privately through
[GitHub security advisories](https://github.com/akshitkrnagpal/t3-boat/security/advisories/new)
instead of a public issue. Include the step or file, what leaked or could leak,
and the agent you used. Do not include a real token, pairing link, or VM ID.

## What the skill does with credentials

- It reuses credentials that already exist on the VM. It never copies them from
  your local machine, and never asks for passwords, tokens, or codes in chat.
- The only credential it writes is an existing `CLAUDE_CODE_OAUTH_TOKEN`, moved
  from the VM's login shell into T3's `service.env` with mode `0600`.
- Authentication checks print a verdict, never raw credential files, process
  environments, `gh auth token`, or `git credential fill` output.
- Pairing links are short-lived and handed to you, never opened by the agent.
- This repository contains no credentials, VM IDs, hostnames, or pairing links,
  and must never gain any.

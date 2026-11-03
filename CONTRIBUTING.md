# Contributing

The skill is instructions an agent adapts to each VM, not an installer. Keep it
that way: describe what to check and why, and avoid one-shot scripts that
assume a fresh machine.

## Rules

- **No personal data.** No VM IDs, tailnet hostnames, IPs, account names,
  tokens, or pairing links in any file, example, or commit message. Use
  placeholders such as `<vm-id>` and `<actual-tailnet-hostname>`.
- **Match the real CLI.** When you add or change a `t3` command or flag, add it
  to the `checks` list in `scripts/check-cli.sh` and run the script against a
  current install (`scripts/check-cli.sh <vm-id>` checks a Boat VM).
- **Keep `SKILL.md` short.** Put detail in `references/` and link to it from
  `SKILL.md`, so agents load it only when the step applies.
- **Do not add defaults** for the release channel or access method. The skill
  asks the user on purpose.

## Releasing

1. Run `scripts/check-cli.sh` against the current stable and nightly releases.
2. Bump `metadata.version` in `SKILL.md` (a renamed skill, removed step, or new
   required question is a major bump) and update `metadata.verified-t3`.
3. Add a `CHANGELOG.md` entry, commit, and tag `v<version>`.

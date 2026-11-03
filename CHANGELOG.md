# Changelog

Versions follow [Semantic Versioning](https://semver.org). The version lives in
`metadata.version` in `SKILL.md`; `metadata.verified-t3` records the T3 Code
releases whose CLI the skill was last checked against with
`scripts/check-cli.sh`.

## 1.0.2 - 2026-11-04

- Pin the Tailscale machine name with `tailscale set --hostname`, so a Boat
  restore that changes the OS hostname no longer breaks the HTTPS origin.
- Detect a stale Serve origin on existing hosts and re-pair under the current
  name.

## 1.0.1 - 2026-11-03

- Fixed restart guidance: `t3 update` run over noninteractive SSH does not
  restart the service without `--yes`, and `t3 service restart` restarts
  immediately without a prompt. Updates now pass `--yes` once the restart is
  agreed and confirm the running version afterwards. Downgrades need
  `--allow-downgrade` with the user's agreement.

## 1.0.0 - 2026-11-03

First tagged release. Verified against T3 Code v0.1.6 (stable) and
v0.1.7-nightly.20261103.4119.

- Renamed the skill from `t3boat-skill` to `t3-boat`. Prompts now use
  `$t3-boat`, and the repository moved to `akshitkrnagpal/t3-boat`.
- Asks for the release channel (stable or nightly) and the access method
  (Tailscale or T3 Connect) without defaulting.
- Configures GitHub CLI and Git credentials, and repairs Claude authentication
  for the background service, notifying the user.
- Keeps an alternate Tailscale Serve HTTPS port in every pairing command when
  port 443 is already in use.
- Optional guidance for exposing an application dev server.
- Added `scripts/check-cli.sh` to detect T3 CLI flags the skill depends on
  disappearing.

# t3boat-skill

An agent skill for installing and repairing [T3 Code](https://t3.codes) on
[Boat](https://boat.dev) VMs. It captures the setup details that are easy to miss
when moving from an SSH shell to a background service.

The skill asks you to choose **stable or nightly** and **Tailscale or T3
Connect**. It also configures GitHub CLI/Git credentials and repairs Claude
authentication automatically, notifying you as it goes. Account authorization
still happens through your own sign-in. Exposing an app's development server
is available when requested.

## Install the skill

With a skill installer that supports GitHub repositories:

```sh
npx skills add akshitkrnagpal/t3boat-skill
```

Or clone directly into your agent's skills directory. For Codex:

```sh
git clone https://github.com/akshitkrnagpal/t3boat-skill.git \
  ~/.codex/skills/t3boat-skill
```

For Claude Code, use `~/.claude/skills/t3boat-skill` instead. If that directory
already exists, update its existing checkout rather than cloning over it.
Reload your agent's skills if it does not discover the new skill immediately.

## Use it

```text
Use $t3boat-skill to set up T3 Code on my Boat VM <vm-id>.
```

You need access through the Boat CLI (`boat ssh <vm-id>`) and a VM that supports
systemd user services, normally Ubuntu. The agent checks prerequisites and
reuses existing installation/account state. Missing CLI/account authentication
may require browser sign-in or administrator access.

The repository contains instructions, not a one-shot installer. The agent
adapts to the VM's actual state, pauses for required account authorization, and
verifies the background service's credentials. It does not create a paid VM,
choose a release channel for you, or publish application ports automatically.

## What the skill handles

- T3 Code installation, updates, and persistent background service setup.
- Tailscale HTTPS pairing or account-based T3 Connect access.
- GitHub CLI login and `gh auth setup-git` for private HTTPS clones.
- Claude credentials available in SSH but missing from T3's service.
- App dev-server binding and tailnet URLs, while preserving T3's HTTPS route.

The operational instructions live in [SKILL.md](SKILL.md). Supporting references
cover [authentication](references/authentication.md),
[remote access](references/remote-access.md), and
[application dev servers](references/dev-servers.md). No personal VM identifiers,
credentials, account-specific hostnames, or pairing tokens belong in this repo.

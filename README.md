# t3-boat

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
npx skills add akshitkrnagpal/t3-boat
```

Or clone it into your agent's skills directory:

```sh
# Claude Code
git clone https://github.com/akshitkrnagpal/t3-boat.git ~/.claude/skills/t3-boat
# Codex
git clone https://github.com/akshitkrnagpal/t3-boat.git ~/.codex/skills/t3-boat
```

If that directory already exists, `git pull` inside it instead. Reload your
agent's skills if it does not discover the new skill immediately.

Claude Code reads only the `name` and `description` in `SKILL.md`, so it needs
no other metadata. `agents/openai.yaml` supplies the display name and default
prompt Codex shows in its UI.

Upgrading from `t3boat-skill`: remove the old skill directory and install
`t3-boat`, then use `$t3-boat` in prompts.

## Use it

```text
Use $t3-boat to set up T3 Code on my Boat VM <vm-id>.
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
[application dev servers](references/dev-servers.md).

## Troubleshooting

**`could not read Username for 'https://github.com': terminal prompts disabled`**
GitHub CLI is logged in but Git is not using it. Run
`gh auth setup-git --hostname github.com` on the VM. No T3 restart is needed.

**Claude works over SSH but T3 says it is not logged in.** Your shell sets
`CLAUDE_CODE_OAUTH_TOKEN` and the systemd service does not inherit it. Ask the
agent to repair Claude authentication; it moves the token into T3's
`service.env` and restarts the service once.

**`t3 pair --tailscale` fails with an access or permission error.** The VM user
is not the Tailscale operator. Run `sudo tailscale set --operator="$(id -un)"`,
unless another operator is already set on purpose.

**Tailscale Serve says HTTPS is not enabled.** Enable HTTPS certificates for
your tailnet in the Tailscale admin console (DNS settings), then pair again.
The first certificate can take a minute to issue.

**The Tailscale HTTPS address stopped resolving after a VM restore.** Boat
changed the VM's hostname and Tailscale followed it. Ask the agent to repair
remote access: it pins the tailnet name with `tailscale set --hostname` and
pairs again. Devices paired to the old address must pair again once.

**The pairing link expired.** Links last five minutes. Run
`t3 pair --tailscale --tailscale-serve-port <port>` again with the same port
you set up. Nothing needs reinstalling, and devices already paired stay paired.

**`t3: command not found` over `boat ssh`.** Non-interactive SSH may not load
your shell's PATH. Use `~/.local/bin/t3`.

**Your app's dev server is unreachable from another device.** Check, in order:
it listens on `0.0.0.0` (not `127.0.0.1`), the framework allows the tailnet
hostname, you used `http://` with the explicit port, and both devices are on
the tailnet. See [application dev servers](references/dev-servers.md).

## Keeping up with T3 Code

`scripts/check-cli.sh` confirms that every `t3` command and flag the skill uses
still exists. Run it locally, or against a VM with `scripts/check-cli.sh <vm-id>`.
`metadata.verified-t3` in `SKILL.md` records the last versions it passed on.

See [CONTRIBUTING.md](CONTRIBUTING.md) for changes and releases,
[SECURITY.md](SECURITY.md) for reporting a credential leak, and
[CHANGELOG.md](CHANGELOG.md) for history. Licensed under [MIT](LICENSE).

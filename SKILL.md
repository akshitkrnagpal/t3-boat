---
name: t3-boat
description: Install or repair T3 Code on a Boat VM through boat ssh, with a chosen stable or nightly release, Tailscale or T3 Connect access, and GitHub and Claude authentication for the background service. Also use for exposing an app dev server on that VM when requested.
license: MIT
metadata:
  version: "1.0.1"
  verified-t3: "v0.1.6 stable, v0.1.7-nightly.20261103.4119"
---

# T3 Code on Boat

Set up a user-owned Boat VM so T3 Code works after the SSH session ends. Run
commands on the VM with `boat ssh <vm-id> '<command>'`; local installation and
VM installation are different operations. Do not create a paid VM unless asked.

## Establish the target and choices

Use the VM identifier supplied by the user. If missing, use `boat list` to
identify candidates and ask which VM. If Boat is absent or logged out, help the
user install/sign into the official [Boat CLI](https://docs.boat.dev/cli-reference).
Do not replace their chosen VM with a new one.

Ask together, unless already answered in the conversation:

- **Release:** stable or nightly?
- **Remote access:** Tailscale or T3 Connect?

Neither choice has a default. Wait for these answers before the dependent
installation/access steps; inspect the VM while waiting. Existing configuration
is useful context, but is not an answer to a new user's release/access choice.
If the user explicitly wants both access methods, support both.

Notify the user that setup includes GitHub CLI configuration and Claude
authentication repair automatically. Do not ask separate permission for those
routine fixes. Browser/account sign-in still requires the user's participation;
never claim it succeeded before checking.

## Inspect before changing

Check OS/architecture, the remote user, `sudo -n true`, systemd user-service
availability, existing `t3`, `gh`, `claude`, and Tailscale installations. A login
shell (`bash -lc` on the usual Ubuntu image) may have a different PATH and
credentials than a noninteractive SSH command. Try `~/.local/bin/t3` explicitly.

If installed, inspect `t3 --version`, `t3 status`, and `t3 service status`. On a
Tailscale host inspect `tailscale status` and `tailscale serve status` too. Avoid
printing entire process environments, credential files, or unfiltered logs.

The supported baseline is Ubuntu with systemd user services. For a different
image, inspect current official support before adapting commands. If user
services or required privileges are unavailable, report the specific limitation;
do not describe a foreground process as an installed background service.

Reuse working components. Preserve existing data, credentials, unrelated
`service.env` entries, and network routes. Do not reimage, delete state, replace
accounts, kill processes by name, or reset Tailscale Serve. On an existing host,
identify active work before any restart/update; defer an interrupting change
until the user agrees or the work finishes. Over noninteractive SSH,
`t3 service restart` restarts immediately with no prompt, while `t3 update`
installs but leaves the service on the old version unless given `--yes`.

## Install the selected T3 release

For a fresh install, run the official installer with the selected channel:

```sh
curl -fsSL https://t3.codes/install.sh | T3CODE_CHANNEL=stable sh
# Or, only when nightly was chosen:
curl -fsSL https://t3.codes/install.sh | T3CODE_CHANNEL=nightly sh
```

Run one command, not both. This installs `~/.local/bin/t3`. For an existing
installation needing an update or channel switch, use
`t3 update --channel <stable-or-nightly> --yes` once the restart is agreed;
without `--yes` the service keeps running its current version. Moving to an
older version (nightly to stable usually is) also needs `--allow-downgrade`;
confirm that with the user, never add it silently. Check `t3 service status`
afterwards for the version actually running.

Verify the actual installed version. Ensure `~/.local/bin` is in the remote
login shell's PATH, adding it to the appropriate startup file only if needed.
Use the absolute binary path for subsequent noninteractive commands. Do not
install Node or an npm copy of T3 just to work around PATH.

## Configure GitHub and Claude automatically

Read [references/authentication.md](references/authentication.md) and perform
both setups. Reuse valid existing logins, configure Git's GitHub credential
helper, and check Claude from the environment used by the T3 server. Complete
independent work while waiting for browser sign-in. A missing login is a pending
step, not permission to invent or copy credentials from another machine.

## Configure the selected access method

Read [references/remote-access.md](references/remote-access.md) for the selected
route, pairing, and verification. Tailscale uses `t3 up --lan` plus
`t3 pair --tailscale --tailscale-serve-port <selected-port>`; T3 Connect uses
`t3 up --connect --headless`. Inspect the
installed CLI's help when flags differ. Preserve access methods already enabled
unless the user asks to turn them off.

Once the service runs, finish the service-environment authentication checks from
the authentication reference. If a repair changes `service.env`, one coordinated
restart is needed. Configuring Git's credential helper needs no restart.

For browser authorization, show the actual URL/code once, explain the action,
and continue independent setup. When nothing independent remains, hand back with
the pending action and resume from status after the user responds. Avoid login
retry loops that invalidate a URL the user is opening. Do not ask for passwords,
API tokens, or authorization codes in chat; use the harness's protected secret
input when a new secret is necessary and supported.

## Optional application development server

Only when requested, read
[references/dev-servers.md](references/dev-servers.md). This exposes the user's
application separately from T3 Code; installing T3 alone does not need it.

## Verify and hand back

Check the installed T3 version, the running service, selected remote access,
GitHub CLI login and Git credential integration, and Claude authentication from
the server environment. Do not run paid agent turns just to test authentication.

For Tailscale, verify the bare HTTPS origin without following a pairing URL,
then mint a fresh short-lived link immediately before handoff. Report the real
origin and link, expiry, and any sign-in still pending. For T3 Connect, confirm
the account link and tell the user to select this environment on another client.

Distinguish checks from inside the VM from checks on another tailnet device.
Never claim remote reachability based only on a VM-local fetch. After the user
confirms pairing, report completion. Useful later commands are `t3 status`,
`t3 service status`, `t3 pair --tailscale --tailscale-serve-port <selected-port>`
(Tailscale), and `t3 update --channel <chosen-channel>`. Preserve the selected
HTTPS port when replacing expired links too. Do not include credentials or
pairing links in committed files.

# GitHub and Claude authentication

These are automatic setup steps: notify the user and proceed with authorized
configuration, reusing their existing VM credentials. Do not switch accounts or
subscription/API providers to make a check pass.

## GitHub CLI and HTTPS clones

1. Check `command -v gh` and `gh auth status` on the VM. Install a missing CLI
   using the current official [GitHub CLI Linux instructions](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).
2. If logged out, run `gh auth login --hostname github.com --git-protocol https
   --web` in an interactive remote terminal (`boat ssh -t <vm-id> ...`). Give
   the user the device URL/code. Recheck after authorization; avoid printing tokens.
3. Run `gh auth setup-git --hostname github.com` even if the existing login is
   valid. This configures Git to use the GitHub CLI credential helper.
4. Check `gh auth status` in the T3 service environment too. Git credentials
   stored in `~/.config/gh/hosts.yml` normally work for the same remote user.
   Shell-only `GH_TOKEN`/`GITHUB_TOKEN` may hide a missing service login; prefer
   the CLI's durable login rather than assuming the shell's state carries over.
5. Verify read access with `GIT_TERMINAL_PROMPT=0 git ls-remote <https-repo-url>
   HEAD` from that environment, using the user's intended repository when known.
   With no repository supplied, verify helper output internally (only print
   whether credentials were supplied), or use an accessible private repository
   if the user authorizes inspecting one. A public clone does not test private
   repository authentication. Do not clone a large repository merely to test auth.

`gh auth status` can succeed while Git clone fails with `could not read Username
for 'https://github.com': terminal prompts disabled`. That is commonly missing
credential-helper integration. `gh auth setup-git` fixes this without restarting
T3. If credentials are supplied but access is denied, investigate repository URL,
token permissions, organization SSO, or account access instead of repeating login.
An SSH URL also needs SSH credentials; prefer HTTPS when using the gh helper,
and do not rewrite unrelated Git remotes or global URL rules.

## Claude: shell authentication versus service authentication

Check `claude auth status` in the VM's login shell. If Claude is absent, install
it using current official [Claude Code setup guidance](https://code.claude.com/docs/en/setup).
Preserve an intentional custom endpoint or organization-managed authentication.

If there is no existing login, use `claude auth login` and let the user complete
the CLI's supported authorization flow. Use a remote interactive terminal if
needed. If completion requires pasting a sensitive code, direct the user to the
terminal or a protected input channel, never ordinary chat.

A login shell may inject `CLAUDE_CODE_OAUTH_TOKEN` even though Claude has no
persisted login. A successful shell check therefore does not prove T3 can use it.
Systemd does not automatically inherit shell startup variables.

### Check the environment T3 actually uses

After starting T3's service, obtain its MainPID using
`systemctl --user show t3code.service -p MainPID --value`. The launcher may have
a child server process: inspect its direct children and command/executable to
identify the server. Do not assume the first child is always the server, and do
not kill any process discovered this way.

For the same user on Linux, a small remote Python program can read
`/proc/<server-pid>/environ`, split NUL-separated `KEY=VALUE` records into a
mapping, and pass that mapping directly as `env=` to
`subprocess.run([<claude-path>, "auth", "status"], ...)`. Do the equivalent for
`gh auth status` and the Git access check. Keep all environment values in memory;
print only the authentication verdict and non-secret diagnostics. If the CLI
supports output with account details/tokens, sanitize it before returning it.
Use the actual server's environment; a new SSH/login shell is not equivalent.

If process-environment access is denied, state that the service-context check
is unverified. Do not infer success from a shell login or claim failure solely
because an inspection mechanism is unavailable.

### Repair a shell-only Claude token

Prefer an existing durable Claude login when it already works in the server
environment. If the shell already provides a working `CLAUDE_CODE_OAUTH_TOKEN`
and the service lacks it, automatically repair that mismatch:

1. Notify the user that the service is missing the existing shell credential.
2. Inside the VM's login shell, read the existing token from the environment in
   Python; never interpolate the token into an SSH command, command argument,
   shell history, or tool output. Do not fetch a token from the local machine.
3. Update only `CLAUDE_CODE_OAUTH_TOKEN` in `~/.t3/service.env` (or the actual
   configured T3 home), preserving unrelated entries. Reject CR/LF in the token.
   Use a temporary file in the same directory opened with mode `0600`, write
   the complete contents, and atomically replace the destination. Preserve file
   ownership; do not follow an unexpected symlink. Do not print the file.
4. Coordinate any active work, then run `t3 service restart`. A noninteractive
   restart can stop agent turns and terminals. For fresh setup there is no need
   to ask again merely to start/restart the newly installed service.
5. Re-run `claude auth status` with the actual server process environment and
   check that `loggedIn` is true. Report unresolved expiry/revocation honestly.

Persisting the existing token makes it available after service restarts; it does
not make it permanent or add token renewal. If it expires, update it through
the credential source or complete a durable CLI login. Do not repeatedly restart
a service to retry an invalid token. Never log `.credentials.json`, `hosts.yml`,
`service.env`, raw `/proc/.../environ`, or the output of `gh auth token` or
`git credential fill`. A boolean credential-presence check is sufficient.

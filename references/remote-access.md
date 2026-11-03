# Remote access

Use the method the user selected. Commands below run as the ordinary VM user
unless `sudo` is shown. Use `~/.local/bin/t3` when PATH is incomplete.

## Tailscale

Install if missing:

```sh
curl -fsSL https://tailscale.com/install.sh | sh
```

Verify `systemctl is-active tailscaled`. If not authenticated, run
`sudo tailscale up`, share its actual browser authorization URL with the user,
and resume after they authorize it. A bounded `--timeout=10s` can keep the shell
call from waiting indefinitely; a timeout while awaiting authorization is not
an installation failure. Recheck `tailscale status` after the user responds.
Reuse an existing account; do not log out or force reauthentication unasked.

Enable the VM user to manage Serve without giving the T3 service root access:

```sh
sudo tailscale set --operator="$(id -un)"
```

This changes the local Tailscale operator. If an existing operator is different,
resolve that ownership conflict with the user rather than replacing it silently.
Check `tailscale ip -4` and discover the real tailnet DNS name from status;
never derive it from a previous VM's name.

Inspect `tailscale serve status` before changing mappings. The desired T3 HTTPS
origin normally proxies `/` on port 443 to `http://127.0.0.1:3773`, but use the
actual T3 port. Reuse a matching route. If `/` already points to another
service, do not overwrite it: choose a supported unused HTTPS Serve port (check
installed `t3 pair --help` for `--tailscale-serve-port`) and retain that port in
all URLs. Never run `tailscale serve reset` or enable public Funnel for this.
Remember the selected HTTPS port (443 if available); the pairing command does
not remember an alternate port between invocations.

Start the background service with tailnet/LAN access:

```sh
t3 up --lan
t3 pair --tailscale --tailscale-serve-port <selected-port>
```

`--lan` makes T3 accept LAN/tailnet connections with pairing authorization.
Tailscale Serve supplies HTTPS so browser clients can reach it. The service and
Serve mapping persist across logouts/reboots on the supported Ubuntu image;
verify the unit is enabled and running rather than assuming it.

If Serve fails, inspect the actual diagnostic. A missing operator grant and
tailnet HTTPS not enabled are different failures. For HTTPS enablement, give
the user the real Tailscale administrator URL/action and resume after completion.
Do not keep retrying `t3 pair` while waiting for approval. Certificate provisioning
can take a moment; use bounded checks and report an endpoint still pending.

Verify the **bare origin**, for example:

```sh
curl --fail --show-error --silent --max-time 20 -o /dev/null \
  -w 'HTTP %{http_code}\n' https://<actual-vm-name>.<actual-tailnet>.ts.net/
```

Use the real discovered origin, including a nonstandard port if configured.
Expect the T3 page (normally HTTP 200); an authorization error proves an HTTP
endpoint exists but does not establish a usable setup. Do not disable TLS
verification to declare success. This fetch from the VM proves server-side
health only. Verify from an available second tailnet device or ask the user to
confirm access; do not invent a second-device result.

Finish authentication repairs and restarts first. Then mint a fresh pairing
link using `t3 pair --tailscale --tailscale-serve-port <selected-port>` and give
the printed URL/app link verbatim,
along with its expiry (normally five minutes). Never navigate or fetch the
pairing URL yourself. Fresh links are for new devices; already paired clients
do not need to pair after every restart. If a link expires, mint another without
reinstalling anything, passing the same selected HTTPS port again. Store neither
tokens nor account-specific URLs in Git.

## T3 Connect

Tailscale is not required for this path. Run:

```sh
t3 up --connect --headless
```

Over SSH the CLI prints a browser URL and short code. Ask the user to open the
URL, confirm the displayed code, and authorize with their T3 account. Do not
confuse this with Tailscale authorization or request an API key instead.

After authorization, inspect `t3 status` and `t3 service status`. Confirm that
T3 Connect is linked/enabled and the service is running. The user signs into the
same account on another client and selects this environment. Do not fabricate
a direct HTTPS origin or Tailscale pairing link for a Connect-only setup.

On a new Connect-only install, leave LAN access off. Existing routes not named
by an access flag keep their settings: preserve them unless the user explicitly
asks for removal. T3 Connect exposes T3; a separate application dev server is
not automatically published through it.

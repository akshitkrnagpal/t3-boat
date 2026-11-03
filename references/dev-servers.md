# Expose an application's development server

Do this when the user asks to view their application remotely. This is separate
from installing T3 Code. Discover the app's existing command, actual port, and
running process first. Avoid starting a second copy or terminating unknown PIDs.

## Over Tailscale

The app must listen on `0.0.0.0` (or a specific reachable tailnet interface), not
only `127.0.0.1`. For a typical npm/Vite app, after checking its script:

```sh
npm run dev -- --host 0.0.0.0 --port 4321
```

This is an example, not a command for every framework or the T3 Code repository.
Use the project's actual package manager and documented dev command. Read the
reported port: a busy port may cause the server to choose another one. Keep the
process in the project's existing persistent session or track the PID you start.

If the framework rejects the tailnet Host header, allow the exact discovered
Tailscale hostname in that project's dev-server configuration. Do not disable
all host validation or bake the VM's address into the frontend bundle. For T3
Code's own source checkout, use its documented `vp run dev` workflow and never
set `VITE_HTTP_URL` or `VITE_WS_URL`; its proxy requires a single origin.

Give both addresses using the real values:

```text
http://<actual-tailnet-hostname>:<actual-dev-port>/
http://<actual-tailscale-ip>:<actual-dev-port>/
```

Use **plain HTTP with the explicit dev port** unless the app already has its
own intentional HTTPS setup. The HTTPS origin without a port may already proxy
T3 Code to port 3773. Leave that mapping alone. Do not replace it with the app
or run Tailscale Serve reset. Tailscale encrypts tailnet traffic; devices must
be connected to the tailnet and permitted by its ACLs/grants.

Check the listener and an HTTP request. A fetch from the VM itself, even to its
Tailscale name/IP, is not proof another device can reach it. Check from another
available tailnet device, or explicitly ask the user to confirm. On failure,
distinguish DNS resolution, listener binding, framework allowed-host rules,
firewall, tailnet ACLs, and the browser trying HTTPS instead of HTTP. Keep hot
reload working through the same origin, with framework-specific WebSocket
configuration only if the app actually requires it.

Binding all interfaces can also expose the app on other networks the VM uses.
Inspect the network/firewall and explain the actual scope; use a tailnet-only
bind or appropriately scoped firewall rule if required. Do not open public Boat
ports or enable Funnel merely to solve private tailnet access.

## T3 Connect without Tailscale

T3 Connect does not automatically route arbitrary application ports. Report
that distinction. Ask which separate app access route the user wants (for
example, an SSH port forward or adding Tailscale); do not silently publish the
app to the internet or change the selected T3 access method.

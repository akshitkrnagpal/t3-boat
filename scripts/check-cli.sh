#!/usr/bin/env bash
# Fails when a T3 CLI command or flag that the skill tells agents to use is gone.
# Usage: scripts/check-cli.sh            # checks the local `t3`
#        scripts/check-cli.sh <vm-id>    # checks ~/.local/bin/t3 on a Boat VM
set -euo pipefail

vm="${1:-}"

t3_help() {
  if [ -n "$vm" ]; then
    boat ssh "$vm" "\$HOME/.local/bin/t3 $* --help" 2>&1
  else
    t3 "$@" --help 2>&1
  fi
}

t3_version() {
  if [ -n "$vm" ]; then
    boat ssh "$vm" '$HOME/.local/bin/t3 --version' 2>&1
  else
    t3 --version 2>&1
  fi
}

# "<subcommand>|<flag> <flag> ..." — keep in sync with SKILL.md and references/.
checks=(
  "up|--lan --connect --headless"
  "pair|--tailscale --tailscale-serve-port"
  "update|--channel --allow-downgrade --yes"
  "status|"
  "service status|"
  "service restart|"
)

echo "Checking $(t3_version)${vm:+ on $vm}"
failed=0
for entry in "${checks[@]}"; do
  cmd="${entry%%|*}"
  flags="${entry#*|}"
  if ! help="$(t3_help $cmd)"; then
    echo "FAIL  t3 $cmd: command missing or --help failed"
    failed=1
    continue
  fi
  for flag in $flags; do
    if grep -qE -- "(^|[[:space:],])${flag}([[:space:],]|$)" <<<"$help"; then
      echo "ok    t3 $cmd $flag"
    else
      echo "FAIL  t3 $cmd $flag"
      failed=1
    fi
  done
  [ -z "$flags" ] && echo "ok    t3 $cmd"
done

if [ "$failed" -ne 0 ]; then
  echo "Update SKILL.md/references for the changed CLI, then bump metadata.version." >&2
  exit 1
fi
echo "All CLI references found. Record this version in metadata.verified-t3."

#!/usr/bin/env bash
#
# keep-awake.sh — keep Render free-tier services from spinning down.
#
# Render free web services sleep after ~15 min of inactivity and cold-start
# (~30-60s) on the next request. While THIS script runs it pings every
# service's auth-exempt /livez endpoint on an interval shorter than that
# window, so nothing sleeps. Stop the script (Ctrl-C) and everything goes
# back to sleep on its own after ~15 min.
#
# Usage:
#   ./scripts/keep-awake.sh                 # ping every 600s (10 min)
#   INTERVAL=300 ./scripts/keep-awake.sh    # custom interval (seconds)
#
# NOTE: keeping services awake 24/7 burns Render's 750 free instance-hours/
# month. Run this only while you're actually using the app.

set -uo pipefail

# Interval between ping rounds, in seconds. Must stay below Render's ~15 min
# (900s) idle timeout — 600s leaves comfortable margin.
INTERVAL="${INTERVAL:-600}"

# Per-request timeout. First hit on a sleeping service is a cold start that
# can take 30-60s, so give it room.
TIMEOUT="${TIMEOUT:-90}"

# Services to keep awake: "name|public-url". The path /livez is appended.
# Public .onrender.com URLs — fill in the three marked TODO from your Render
# dashboard (each service's public URL).
SERVICES=(
  "gateway-api|https://gateway-api-1j5h.onrender.com"
  "orders-api|https://orders-api-hgxh.onrender.com"
  "users-api|https://users-api-wr4g.onrender.com"
  "items-api|https://items-api-fvnj.onrender.com"
  "metrics-api|https://metrics-api-i0r3.onrender.com"
  "password-recovery-bridge|https://app-bridge.onrender.com"
)

# Health path. Every service whitelists /livez (no auth, cheap).
# The bridge has no /livez, so it falls back to "/" — handled below.
HEALTH_PATH="/livez"

ping_one() {
  local name="$1" base="$2" path="$HEALTH_PATH"
  # password-recovery-bridge has no /livez — just hit root to wake it.
  [[ "$name" == "password-recovery-bridge" ]] && path="/"

  local out code time
  out=$(curl -fsS -o /dev/null -L \
    --max-time "$TIMEOUT" \
    -w '%{http_code} %{time_total}' \
    "${base}${path}" 2>/dev/null)
  local rc=$?

  if [[ $rc -eq 0 ]]; then
    code="${out% *}"; time="${out#* }"
    printf '  \033[32m✓\033[0m %-26s %s  (%ss)\n' "$name" "$code" "$time"
  else
    printf '  \033[31m✗\033[0m %-26s curl error %s  (%s)\n' "$name" "$rc" "${base}${path}"
  fi
}

ping_round() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] pinging ${#SERVICES[@]} services…"
  # Fire all pings in parallel so a cold start on one doesn't block the rest.
  for entry in "${SERVICES[@]}"; do
    ping_one "${entry%%|*}" "${entry#*|}" &
  done
  wait
}

on_exit() {
  echo
  echo "Stopped. Services will spin down after ~15 min of inactivity."
  exit 0
}
trap on_exit INT TERM

echo "keep-awake: pinging every ${INTERVAL}s (Ctrl-C to stop)."
echo "First round wakes everything — cold starts may take up to ${TIMEOUT}s."
echo

while true; do
  ping_round
  sleep "$INTERVAL"
done

#!/usr/bin/env bash
# Snapper snapshot limit configuration (Fedora/btrfs)

SNAPPER_LIMIT="${SNAPPER_LIMIT:-6}"

_snapper_set_kv() {
  local file="$1" key="$2" value="$3"
  if grep -qE "^${key}=" "$file"; then
    run_as_root sed -i "s/^${key}=.*/${key}=\"${value}\"/" "$file"
  else
    printf '%s="%s"\n' "$key" "$value" | run_as_root tee -a "$file" >/dev/null
  fi
}

configure_snapper_limits() {
  local limit="${1:-$SNAPPER_LIMIT}"

  if ! command -v snapper &>/dev/null; then
    warn "snapper not installed; skipping snapshot limit configuration"
    return 0
  fi

  local configs=()
  if [[ -d /etc/snapper/configs ]]; then
    while IFS= read -r -d '' cfg; do
      configs+=("$cfg")
    done < <(find /etc/snapper/configs -maxdepth 1 -type f ! -name '.*' -print0 2>/dev/null)
  fi

  if [[ ${#configs[@]} -eq 0 ]]; then
    warn "No snapper config files found under /etc/snapper/configs"
    return 0
  fi

  local config config_name
  for config in "${configs[@]}"; do
    [[ -f "$config" ]] || continue
    config_name="$(basename "$config")"
    log "Configuring snapper limits in ${config} (keep ${limit} snapshots)"

    _snapper_set_kv "$config" NUMBER_CLEANUP yes
    _snapper_set_kv "$config" NUMBER_MIN_AGE 0
    _snapper_set_kv "$config" NUMBER_LIMIT "$limit"
    _snapper_set_kv "$config" NUMBER_LIMIT_IMPORTANT "$limit"

    if grep -qE '^TIMELINE_CREATE="yes"' "$config" 2>/dev/null \
      || grep -qE '^TIMELINE_CLEANUP="yes"' "$config" 2>/dev/null; then
      _snapper_set_kv "$config" TIMELINE_CLEANUP yes
      _snapper_set_kv "$config" TIMELINE_LIMIT_HOURLY 0
      _snapper_set_kv "$config" TIMELINE_LIMIT_DAILY 0
      _snapper_set_kv "$config" TIMELINE_LIMIT_WEEKLY 0
      _snapper_set_kv "$config" TIMELINE_LIMIT_MONTHLY 0
      _snapper_set_kv "$config" TIMELINE_LIMIT_QUARTERLY 0
      _snapper_set_kv "$config" TIMELINE_LIMIT_YEARLY 0
    fi

    log "Running snapper cleanup for config ${config_name}..."
    run_as_root snapper -c "$config_name" cleanup number 2>/dev/null \
      || warn "number cleanup failed for ${config_name}"
    run_as_root snapper -c "$config_name" cleanup timeline 2>/dev/null || true

    ok "Snapper limits set for ${config_name}"
  done
}

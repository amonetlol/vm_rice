#!/usr/bin/env bash
# Enable RPM Fusion and other third-party repos for Fedora
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_fedora

fedora_ver="$(rpm -E %fedora)"

enable_rpmfusion() {
  local repo variant url
  for variant in free nonfree; do
    repo="rpmfusion-${variant}-release-${fedora_ver}"
    url="https://download1.rpmfusion.org/${variant}/fedora/rpmfusion-${variant}-release-${fedora_ver}.noarch.rpm"
    if rpm -q "$repo" &>/dev/null; then
      ok "RPM Fusion ${variant} already enabled"
    else
      log "Enabling RPM Fusion ${variant}..."
      run_as_root dnf install -y "$url"
      ok "RPM Fusion ${variant} enabled"
    fi
  done
}

enable_brave_repo() {
  if rpm -q brave-browser &>/dev/null || [[ -f /etc/yum.repos.d/brave-browser.repo ]]; then
    ok "Brave browser repo already configured"
    return 0
  fi
  log "Adding Brave browser repository..."
  run_as_root dnf install -y dnf-plugins-core
  run_as_root dnf config-manager --add-repo \
    https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
  run_as_root rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
  ok "Brave browser repo added"
}

main() {
  run_as_root dnf install -y dnf-plugins-core
  enable_rpmfusion
  enable_brave_repo
  ok "Third-party repositories configured"
}

main

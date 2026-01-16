#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cfg_dir="$repo_root/config"

ts="$(date +%Y%m%d_%H%M%S)"

platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
flavor="$platform"
if [[ "$platform" == "linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
  flavor="wsl"
fi

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    cp -a "$path" "${path}.bak.${ts}"
  fi
}

deploy_file() {
  local src="$1"
  local dst="$2"
  backup_if_exists "$dst"
  cp -a "$src" "$dst"
  chmod 0644 "$dst"
}

deploy_platform_override() {
  local base="$1"           # zshrc.platform or zprofile.platform
  local dst="$2"            # ~/.zshrc.platform or ~/.zprofile.platform
  local src=""

  if [[ -f "$cfg_dir/${base}.${flavor}" ]]; then
    src="$cfg_dir/${base}.${flavor}"
  elif [[ -f "$cfg_dir/${base}.${platform}" ]]; then
    src="$cfg_dir/${base}.${platform}"
  fi

  if [[ -n "$src" ]]; then
    deploy_file "$src" "$dst"
  else
    backup_if_exists "$dst"
    printf "%s\n" "# No override for platform: $flavor" >"$dst"
    chmod 0644 "$dst"
  fi
}

deploy_file "$cfg_dir/zshrc" "$HOME/.zshrc"
deploy_platform_override "zshrc.platform" "$HOME/.zshrc.platform"

deploy_file "$cfg_dir/zprofile" "$HOME/.zprofile"
deploy_platform_override "zprofile.platform" "$HOME/.zprofile.platform"

echo "OK: deployed zsh dotfiles (platform: $flavor, backup suffix: $ts)"
echo "  - ~/.zshrc"
echo "  - ~/.zshrc.platform"
echo "  - ~/.zprofile"
echo "  - ~/.zprofile.platform"


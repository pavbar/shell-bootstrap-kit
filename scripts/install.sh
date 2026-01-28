#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [--with-brew] [--enable-omz-auto-update]

Installs prerequisites for this repo's Zsh environment and deploys dotfiles.

Options:
  --with-brew                 If brew is available, run `brew bundle install`.
  --enable-omz-auto-update     Try to enable oh-my-zsh auto-update via ~/.zshrc.local.
EOF
}

with_brew="false"
enable_omz_auto_update="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-brew) with_brew="true" ;;
    --enable-omz-auto-update) enable_omz_auto_update="true" ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: missing required command: $cmd" >&2
    return 1
  fi
}

need_cmd git
need_cmd zsh

zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
zsh_custom="${ZSH_CUSTOM:-$zsh_dir/custom}"

install_oh_my_zsh() {
  if [[ -f "$zsh_dir/oh-my-zsh.sh" ]]; then
    echo "OK: oh-my-zsh already installed at $zsh_dir"
    return 0
  fi

  if [[ -e "$zsh_dir" && ! -d "$zsh_dir" ]]; then
    echo "ERROR: ZSH path exists but is not a directory: $zsh_dir" >&2
    return 1
  fi

  echo "Installing oh-my-zsh into $zsh_dir"
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
}

install_plugin() {
  local name="$1"
  local url="$2"
  local dst="$zsh_custom/plugins/$name"

  if [[ -d "$dst/.git" ]]; then
    echo "OK: plugin already present: $name"
    return 0
  fi

  mkdir -p "$(dirname -- "$dst")"
  echo "Installing plugin: $name"
  git clone --depth 1 "$url" "$dst"
}

maybe_enable_omz_auto_update() {
  if [[ "$enable_omz_auto_update" != "true" ]]; then
    return 0
  fi

  local local_rc="$HOME/.zshrc.local"
  local marker="zstyle ':omz:update' mode auto"

  if [[ -f "$local_rc" ]]; then
    if grep -F -- "$marker" "$local_rc" >/dev/null 2>&1; then
      echo "OK: oh-my-zsh auto-update already enabled in $local_rc"
      return 0
    fi

    echo "NOTE: $local_rc exists - not modifying it."
    echo "  To enable oh-my-zsh auto-update, add this line:"
    echo "  $marker"
    return 0
  fi

  echo "Enabling oh-my-zsh auto-update in $local_rc"
  {
    echo "# Local overrides (not managed by Shell Bootstrap Kit)."
    echo "$marker"
  } >"$local_rc"
}

install_oh_my_zsh
install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

"$repo_root/scripts/deploy.sh"

if [[ "$with_brew" == "true" ]] && command -v brew >/dev/null 2>&1; then
  echo "Running: brew bundle install"
  (cd -- "$repo_root" && brew bundle install)
elif [[ "$with_brew" == "true" ]]; then
  echo "NOTE: --with-brew set, but brew is not installed - skipping."
fi

maybe_enable_omz_auto_update

echo "OK: install complete"

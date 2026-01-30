---
title: "Shell Bootstrap Kit"
---

## What this is
A small, cross-platform Zsh setup that supports:
- One base config (shared)
- Per-platform overrides (selected at deploy time)
- Clean redeploys (your custom bits live in `~/.zshrc.local`)

This repo contains no secrets. Keep secrets out of `~/.zshrc.local` too.

## Layout
- `config/zshrc` - base `~/.zshrc` (cross-platform)
- `config/zshrc.platform.*` - platform overrides (deployed to `~/.zshrc.platform`)
- `config/zprofile` - base `~/.zprofile`
- `config/zprofile.platform.*` - platform overrides (deployed to `~/.zprofile.platform`)
- `scripts/deploy.sh` - deploys dotfiles with backups and selects platform override

## Install and deploy
From the repo root:

```bash
scripts/install.sh
exec zsh
```

### Requirements
- `zsh`
- `git`
- Network access to GitHub for fetching `oh-my-zsh` and plugins

macOS notes:
- If you want to use `Brewfile`, install Homebrew first.

If you want Homebrew packages installed on macOS (optional):

```bash
scripts/install.sh --with-brew
exec zsh
```

### What `scripts/install.sh` does
1. Installs `oh-my-zsh` into `${ZSH:-~/.oh-my-zsh}` if missing.
2. Installs plugins into `${ZSH_CUSTOM:-$ZSH/custom}/plugins/`:
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
3. Deploys repo-managed dotfiles via `scripts/deploy.sh` (with backups).
4. Optionally runs `brew bundle install` if `--with-brew` is set and `brew` exists.
5. Optionally enables oh-my-zsh auto-update in `~/.zshrc.local` (only if that file does not already exist).

### Files written (and backups)
`scripts/deploy.sh` writes:
- `~/.zshrc`
- `~/.zshrc.platform`
- `~/.zprofile`
- `~/.zprofile.platform`

If any of those files already exist, it copies them to `*.bak.<timestamp>` first.

### oh-my-zsh updates
- Default: normal oh-my-zsh update checks (may prompt).
- To enable auto-update (no prompts), run `scripts/install.sh --enable-omz-auto-update` or add `zstyle ':omz:update' mode auto` to `~/.zshrc.local`.

If you want maximum stability, do not enable auto-update and instead update oh-my-zsh manually when you choose.

## Customize (safe)
- Put aliases/functions in `~/.zshrc.local`
- Put login-only env changes in `~/.zprofile.local`

Those files are not managed by this repo.

Templates:
- `config/zshrc.local.template` - copy to `~/.zshrc.local`

## Updating
From the repo root:

```bash
git pull
scripts/install.sh
exec zsh
```

This is safe to re-run. It redeploys the managed dotfiles and keeps your personal overrides in `~/.zshrc.local`.

## Homebrew bundle (macOS)
This repo includes a minimal `Brewfile` you can extend.

```bash
brew bundle install
```

## Platform selection
`scripts/deploy.sh` detects:
- `darwin` - macOS
- `linux` - Linux (non-WSL)
- `wsl` - WSL on Linux

It deploys the matching `config/zshrc.platform.<platform>` and `config/zprofile.platform.<platform>` if present.

## Uninstall / rollback
- Restore backups created by `scripts/deploy.sh` (look for `~/.zshrc.bak.<timestamp>` etc).
- Optionally remove `oh-my-zsh` and plugins:
  - `${ZSH:-~/.oh-my-zsh}`
  - `${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions`
  - `${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting`

## Troubleshooting
- No changes after install: run `exec zsh` or open a new terminal.
- CI/headless shells: `config/zshrc` exits early when the shell is non-interactive or missing a TTY.
- Plugin not found: re-run `scripts/install.sh` (it installs missing plugins).

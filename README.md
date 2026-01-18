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
scripts/deploy.sh
exec zsh
```

If you plan to publish this as a git repo, move this folder out of `fel-notes/tmp/` first.

## Customize (safe)
- Put aliases/functions in `~/.zshrc.local`
- Put login-only env changes in `~/.zprofile.local`

Those files are not managed by this repo.

Templates:
- `config/zshrc.local.template` - copy to `~/.zshrc.local`

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

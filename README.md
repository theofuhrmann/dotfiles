# dotfiles

My personal configuration files. Tracked here, symlinked into `$HOME`.

## Layout

Configuration is grouped by what consumes it:

- `home/` → files linked directly into `$HOME`
  - `.zshenv` → `~/.zshenv`
  - `.zshrc` → `~/.zshrc`
  - `.aliases` → `~/.aliases`
  - `.functions` → `~/.functions`
  - `.vimrc` → `~/.vimrc`
- `apps/vscode/settings.json` → VS Code user settings on macOS or Linux
- `apps/vscode/extensions.txt` → extensions installed by `install.sh`
- `agents/claude/` → user-global [Claude Code](https://claude.com/claude-code) config (applies to every project on the machine)
  - `CLAUDE.md` — personal preferences (dictation handling, `uv run --script`, rebase-over-merge, file naming)
  - `agents/` — reviewer subagents: `architect-reviewer`, `researcher-reviewer`, `senior-mle-reviewer`
  - `skills/` — `deslop-code`, `deslop-prose`
- `.github/workflows/gitleaks.yml` → scans pushes and pull requests for committed secrets

The Claude config is adapted from [Anil Keshwani's dotfiles](https://github.com/anilkeshwani/dotfiles/tree/main/home/.claude) (journalling/Obsidian pieces and his personal `settings.json` intentionally omitted).

## Install

```bash
git clone git@github.com:theofuhrmann/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is idempotent: it symlinks tracked files into `$HOME`, replacing stale
symlinks and backing up any real file it would overwrite to `*.bak`. `agents/` and
`skills/` are created as real directories holding per-item symlinks, so agents or
skills you install locally through Claude Code live alongside the tracked ones
without being committed here. If the VS Code `code` command is available, the
installer also installs the extensions listed in `apps/vscode/extensions.txt`.

Secrets are deliberately not tracked. If `~/.secrets` exists, `.zshrc` sources it;
recreate that file from Bitwarden on each machine and restrict it with `chmod 600`.
Gitleaks also scans every push and pull request through GitHub Actions. A passing scan
does not make it safe to commit a secret; credentials committed even briefly should
still be revoked and rotated.

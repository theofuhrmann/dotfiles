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
  - `statusline-command.sh` — status line: directory, git branch, PR, model and
    reasoning effort, context remaining, weekly rate limit, token count
- `agents/codex/config.toml` → Codex preferences, tracked as a reference copy rather
  than symlinked (see below)
- `.github/workflows/gitleaks.yml` → scans pushes and pull requests for committed secrets

The Claude config is adapted from [Anil Keshwani's dotfiles](https://github.com/anilkeshwani/dotfiles/tree/main/home/.claude) (journalling/Obsidian pieces and his personal `settings.json` intentionally omitted).

## Install

```bash
git clone git@github.com:theofuhrmann/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Claude Code's `settings.json` is not tracked, because Claude Code rewrites it. To use
the status line, point it at the symlinked script yourself:

```json
{
  "statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" }
}
```

Codex is not symlinked either, for the same reason: it rewrites `~/.codex/config.toml`
in place with project trust entries and first-run state. `agents/codex/config.toml`
holds the portable subset — model, reasoning effort, plugin toggles, status line — to
apply by hand. Machine-local and account-local sections are omitted deliberately.

This repository is public. Codex and Claude configs accumulate absolute `$HOME` paths
and per-project trust entries naming private repositories, so check any config added
here for employer-internal paths, repository names, and ticket identifiers first.

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

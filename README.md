# dotfiles

My personal configuration files. Tracked here, symlinked into `$HOME`.

## Layout

Files mirror their location under `$HOME`:

- `.vimrc` → `~/.vimrc`
- `.claude/` → user-global [Claude Code](https://claude.com/claude-code) config (applies to every project on the machine)
  - `CLAUDE.md` — personal preferences (dictation handling, `uv run --script`, rebase-over-merge, file naming)
  - `agents/` — reviewer subagents: `architect-reviewer`, `researcher-reviewer`, `senior-mle-reviewer`
  - `skills/` — `deslop-code`, `deslop-prose`

The `.claude/` config is adapted from [Anil Keshwani's dotfiles](https://github.com/anilkeshwani/dotfiles/tree/main/home/.claude) (journalling/Obsidian pieces and his personal `settings.json` intentionally omitted).

## Install

```bash
git clone git@github.com:theofuhrmann/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is idempotent: it symlinks tracked files into `$HOME`, replacing stale
symlinks and backing up any real file it would overwrite to `*.bak`. `agents/` and
`skills/` are created as real directories holding per-item symlinks, so agents or
skills you install locally through Claude Code live alongside the tracked ones
without being committed here.

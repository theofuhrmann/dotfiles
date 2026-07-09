#!/usr/bin/env bash
# Idempotent installer: symlinks tracked dotfiles into $HOME.
# Re-running is safe. Existing non-symlink files are backed up to *.bak.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"                                   # replace stale symlink
  elif [ -e "$dst" ]; then
    echo "  backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -s "$src" "$dst"
  echo "  linked $dst -> $src"
}

echo "Installing dotfiles from $REPO"

# --- shell / editor ---
link "$REPO/.vimrc" "$HOME/.vimrc"

# --- Claude Code (user-global config; applies to all projects) ---
# CLAUDE.md as a file symlink; agents/ and skills/ as real dirs holding
# per-item symlinks so locally-installed agents/skills can coexist without
# being committed to this repo.
link "$REPO/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

mkdir -p "$HOME/.claude/agents" "$HOME/.claude/skills"
for a in "$REPO"/.claude/agents/*.md; do
  link "$a" "$HOME/.claude/agents/$(basename "$a")"
done
for s in "$REPO"/.claude/skills/*/; do
  link "${s%/}" "$HOME/.claude/skills/$(basename "$s")"
done

echo "Done."

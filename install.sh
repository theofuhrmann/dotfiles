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

clone_if_missing() {
  local repo="$1" dst="$2"
  if [ -d "$dst/.git" ]; then
    echo "  found $dst"
  elif [ -e "$dst" ]; then
    echo "  skipping $dst (already exists and is not a Git checkout)"
  else
    git clone --depth=1 "$repo" "$dst"
  fi
}

echo "Installing dotfiles from $REPO"

# --- shell / editor ---
link "$REPO/home/.zshenv" "$HOME/.zshenv"
link "$REPO/home/.zshrc" "$HOME/.zshrc"
link "$REPO/home/.aliases" "$HOME/.aliases"
link "$REPO/home/.functions" "$HOME/.functions"
link "$REPO/home/.vimrc" "$HOME/.vimrc"

if command -v git >/dev/null 2>&1; then
  mkdir -p "$HOME/.zsh"
  clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  clone_if_missing https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.zsh/spaceship"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
else
  echo "  skipping Zsh prompt dependencies (git is unavailable)"
fi

# --- VS Code ---
case "$(uname -s)" in
  Darwin) vscode_user_dir="$HOME/Library/Application Support/Code/User" ;;
  Linux) vscode_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User" ;;
  *) vscode_user_dir="" ;;
esac

if [ -n "$vscode_user_dir" ]; then
  link "$REPO/apps/vscode/settings.json" "$vscode_user_dir/settings.json"
fi

if command -v code >/dev/null 2>&1; then
  while IFS= read -r extension; do
    code --install-extension "$extension"
  done < "$REPO/apps/vscode/extensions.txt"
else
  echo "  skipping VS Code extensions (the 'code' command is unavailable)"
fi

# --- Claude Code (user-global config; applies to all projects) ---
# CLAUDE.md as a file symlink; agents/ and skills/ as real dirs holding
# per-item symlinks so locally-installed agents/skills can coexist without
# being committed to this repo.
link "$REPO/agents/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

mkdir -p "$HOME/.claude/agents" "$HOME/.claude/skills"
for a in "$REPO"/agents/claude/agents/*.md; do
  link "$a" "$HOME/.claude/agents/$(basename "$a")"
done
for s in "$REPO"/agents/claude/skills/*/; do
  link "${s%/}" "$HOME/.claude/skills/$(basename "$s")"
done

echo "Done."

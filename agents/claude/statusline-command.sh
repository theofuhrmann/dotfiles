#!/bin/bash
# Claude Code status line: mirrors the segment order of the user's Codex TUI
# status line (~/.codex/config.toml [tui] status_line), mapped onto the
# fields Claude Code actually exposes in its statusLine JSON payload:
#
#   Codex segment          Claude Code source
#   ----------------------  ------------------------------------------------
#   current-dir             workspace.current_dir (basename)
#   git-branch              git symbolic-ref / rev-parse, dirty via git status
#   pull-request-number     .pr.number / .pr.kind / .pr.review_state
#   model-with-reasoning    .model.display_name + .effort.level (or thinking)
#   context-remaining       .context_window.remaining_percentage
#   weekly-limit            .rate_limits.seven_day.used_percentage
#   used-tokens             .context_window.total_input_tokens + output
#
# Codex's "fast-mode" and "task-progress" segments have no equivalent field
# in Claude Code's statusLine JSON payload, so they are omitted here.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dir_name=$(basename "$cwd")

BLUE=$'\033[34m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
MAGENTA=$'\033[35m'
RED=$'\033[31m'
GRAY=$'\033[2m'
RESET=$'\033[0m'

segments=()

segments+=("${CYAN}${dir_name}${RESET}")

if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    segments+=("${YELLOW}${branch} ✗${RESET}")
  else
    segments+=("${GREEN}${branch}${RESET}")
  fi
fi

pr_number=$(echo "$input" | jq -r '.pr.number // empty')
if [ -n "$pr_number" ]; then
  pr_kind=$(echo "$input" | jq -r '.pr.kind // empty')
  pr_state=$(echo "$input" | jq -r '.pr.review_state // empty')
  if [ "$pr_kind" = "mr" ]; then
    pr_label="!${pr_number}"
  else
    pr_label="#${pr_number}"
  fi
  if [ -n "$pr_state" ]; then
    segments+=("${MAGENTA}${pr_label} (${pr_state})${RESET}")
  else
    segments+=("${MAGENTA}${pr_label}${RESET}")
  fi
fi

model_name=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model_name" ]; then
  effort=$(echo "$input" | jq -r '.effort.level // empty')
  thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
  if [ -n "$effort" ]; then
    segments+=("${BLUE}${model_name} [${effort}]${RESET}")
  elif [ "$thinking" = "true" ]; then
    segments+=("${BLUE}${model_name} (thinking)${RESET}")
  else
    segments+=("${BLUE}${model_name}${RESET}")
  fi
fi

ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$ctx_remaining" ]; then
  segments+=("${YELLOW}ctx $(printf '%.0f' "$ctx_remaining")%${RESET}")
fi

weekly=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$weekly" ]; then
  segments+=("${RED}7d $(printf '%.0f' "$weekly")%${RESET}")
fi

used_tokens=$(echo "$input" | jq -r '((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0))')
if [ "$used_tokens" -gt 0 ] 2>/dev/null; then
  if [ "$used_tokens" -ge 1000000 ]; then
    formatted=$(awk -v n="$used_tokens" 'BEGIN { printf "%.1fM", n/1000000 }')
  elif [ "$used_tokens" -ge 1000 ]; then
    formatted=$(awk -v n="$used_tokens" 'BEGIN { printf "%.1fk", n/1000 }')
  else
    formatted="$used_tokens"
  fi
  segments+=("${GRAY}${formatted} tok${RESET}")
fi

sep=" ${GRAY}|${RESET} "
out=""
for seg in "${segments[@]}"; do
  if [ -z "$out" ]; then
    out="$seg"
  else
    out="${out}${sep}${seg}"
  fi
done

printf "%s" "$out"

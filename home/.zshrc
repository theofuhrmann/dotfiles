export ZSH="$HOME/.oh-my-zsh"

# Spaceship provides the prompt, so Oh My Zsh does not need a theme.
ZSH_THEME=""
plugins=(git)

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases"
[[ -r "$HOME/.functions" ]] && source "$HOME/.functions"
[[ -r "$HOME/.secrets" ]] && source "$HOME/.secrets"

if [[ -x "$HOME/miniconda3/bin/conda" ]]; then
  __conda_setup="$("$HOME/miniconda3/bin/conda" shell.zsh hook 2>/dev/null)"
  if (( $? == 0 )); then
    eval "$__conda_setup"
  elif [[ -r "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/miniconda3/bin:$PATH"
  fi
  unset __conda_setup
fi

for spaceship in \
  /opt/homebrew/opt/spaceship/spaceship.zsh \
  /usr/local/opt/spaceship/spaceship.zsh; do
  if [[ -r "$spaceship" ]]; then
    source "$spaceship"
    break
  fi
done
unset spaceship

for autosuggestions in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [[ -r "$autosuggestions" ]]; then
    source "$autosuggestions"
    break
  fi
done
unset autosuggestions

# Syntax highlighting must be loaded after other shell plugins.
for syntax_highlighting in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [[ -r "$syntax_highlighting" ]]; then
    source "$syntax_highlighting"
    break
  fi
done
unset syntax_highlighting

[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

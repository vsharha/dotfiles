# === p10k instant prompt — keep at the VERY TOP, above everything ===
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === completions (must come before compinit) ===
fpath=(/opt/homebrew/share/zsh-completions $fpath)
autoload -Uz compinit && compinit

# === powerlevel10k theme ===
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# === PATH / environment ===========================================
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/vsharha/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/go/bin:$PATH"

# Added by Antigravity
export PATH="/Users/vsharha/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/vsharha/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# === aliases ======================================================
alias python=python3
alias pip='pip3'
alias shadcn='pnpm dlx shadcn@latest'
alias shadcn-sv='pnpm dlx shadcn-svelte@latest'
alias cc="claude --dangerously-skip-permissions"

# === fzf (fuzzy Ctrl-R history, Ctrl-T files, Alt-C cd) ===========
source <(fzf --zsh)

# === autosuggestions (grey history hints, → to accept) ============
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# === history substring search (↑/↓ filters by substring) ==========
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# === syntax highlighting (MUST be last of the plugin sources) =====
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# === p10k prompt config — keep at the very BOTTOM =================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

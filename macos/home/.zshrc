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

# === fzf-tab (replaces the completion menu with an fzf picker) =====
# Must load after compinit/fzf and BEFORE autosuggestions & syntax-highlighting.
zstyle ':completion:*' menu no                     # let fzf-tab own the menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group '<' '>'           # < / > to switch groups
source /opt/homebrew/share/fzf-tab/fzf-tab.zsh

# === autosuggestions (grey history hints, → to accept) ============
# Prefer the completion system over raw history so suggestions for cd (and any
# path argument) are validated against the current directory -- the history
# strategy alone happily suggests paths that don't exist from where you are.
ZSH_AUTOSUGGEST_STRATEGY=(completion history)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# === history substring search (↑/↓ filters by substring) ==========
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# === Tab / Shift-Tab behaviour ====================================
# Tab: accept the grey autosuggestion if showing, else open the fzf-tab picker.
# Shift-Tab: always open the fzf-tab picker (type to filter, arrows to move,
#            Enter to select, Esc to cancel).
#
# zsh-autosuggestions wraps every widget as a "modify" widget, which blanks
# $POSTDISPLAY before the widget body runs -- so smart-tab could never see the
# suggestion. Listing it in ZSH_AUTOSUGGEST_IGNORE_WIDGETS leaves it unwrapped.
typeset -ga ZSH_AUTOSUGGEST_IGNORE_WIDGETS
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(smart-tab)

smart-tab() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept                       # grey suggestion -> accept it
  else
    zle fzf-tab-complete                         # else open the fzf picker
  fi
}
zle -N smart-tab
bindkey '^I'   smart-tab                          # Tab
bindkey '^[[Z' fzf-tab-complete                   # Shift-Tab -> fzf picker

# === syntax highlighting (MUST be last of the plugin sources) =====
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# === p10k prompt config — keep at the very BOTTOM =================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# === p10k instant prompt — keep at the VERY TOP, above everything ===
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === completions (must come before compinit) ===
# ~/.zfunc must precede the Homebrew/system dirs so its overrides (e.g. _pnpm) win.
fpath=(~/.zfunc /opt/homebrew/share/zsh-completions $fpath)
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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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
# completion before history so path args (cd) are validated against the real
# cwd; raw history alone suggests stale paths that don't exist from here.
ZSH_AUTOSUGGEST_STRATEGY=(completion history)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# === history substring search (↑/↓ filters by substring) ==========
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# === Tab / Shift-Tab behaviour ====================================
# zsh-autosuggestions wraps every widget to blank $POSTDISPLAY before it runs, so
# smart-tab could never see the suggestion; IGNORE_WIDGETS leaves it unwrapped.
typeset -ga ZSH_AUTOSUGGEST_IGNORE_WIDGETS
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(smart-tab)

# Tab: accept the grey suggestion if showing, else open the fzf-tab picker.
smart-tab() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    zle fzf-tab-complete
  fi
}
zle -N smart-tab
bindkey '^I'   smart-tab                          # Tab

# Shift-Tab: list on the FIRST press. Otherwise fzf-tab inserts the longest
# common prefix (e.g. `drive:`) and only opens the picker on the second press --
# it does that whenever $compstate[insert] ends in "unambiguous". Blanking that
# (only while our guard is set) defeats the early-return so the picker opens at
# once. $compstate[unambiguous] is read-only, hence patching insert instead.
functions[_ftb__main_complete_orig]=$functions[_ftb__main_complete]
_ftb__main_complete() {
  _ftb__main_complete_orig "$@"
  local ret=$?
  (( ${+_ftb_force_list} )) && compstate[insert]=
  return ret
}
fzf-tab-list() {
  typeset -g _ftb_force_list=1
  zle fzf-tab-complete
  unset _ftb_force_list
}
zle -N fzf-tab-list
bindkey '^[[Z' fzf-tab-list                       # Shift-Tab

# === syntax highlighting (MUST be last of the plugin sources) =====
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# === p10k prompt config — keep at the very BOTTOM =================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

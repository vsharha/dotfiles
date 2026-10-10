# Powerlevel10k prompt: the rainbow preset that ships with p10k, then the
# settings below. The wizard options this started from were nerdfont-v3 +
# powerline, small icons, rainbow, unicode, 24h time, slanted separators, sharp
# heads, blurred tails, 2 lines, disconnected, no frame, sparse, many icons,
# concise, transient_prompt, instant_prompt=verbose.
#
# Homebrew ships an older p10k than CachyOS and the Debian clone, and the
# preset differs between them. Settings that only a newer preset adds or
# changes (the yazi segment, tofu, .mise.toml) are set back here, so the prompt
# is the same on every machine. Every variable a preset sets is listed in
# $__p9k_root_dir/config/p10k-rainbow.zsh with a comment on what it does.
#
# `p10k configure` overwrites this file with a full generated config.

source "$__p9k_root_dir/config/p10k-rainbow.zsh"

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Ghostty gets the full two-line prompt. Other terminals, such as a console
  # or a client without the Nerd Font, get the prompt character alone.
  if [[ ${TERM:-} == xterm-ghostty ]]; then
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs newline prompt_char)
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      status command_execution_time background_jobs direnv asdf virtualenv
      anaconda pyenv goenv nodenv nvm nodeenv rbenv rvm fvm luaenv jenv plenv
      perlbrew phpenv scalaenv haskell_stack kubecontext terraform aws
      aws_eb_env azure gcloud google_app_cred toolbox nordvpn ranger nnn lf
      xplr vim_shell midnight_commander nix_shell chezmoi_shell todo
      timewarrior taskwarrior per_directory_history newline
    )
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  else
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(prompt_char)
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  fi

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3

  # Two lines with no frame: nothing joins them.
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

  # Slanted separators, sharp heads, blurred tails.
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\u2571'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\u2571'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0BC'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0BA'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='░▒▓'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='▓▒░'

  # The prompt character stays green after a failed command; the status
  # segment is off for both outcomes.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=false

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  # The preset declares this an array, so it is unset before taking a string.
  unset POWERLEVEL9K_BATTERY_STAGES
  typeset -g POWERLEVEL9K_BATTERY_STAGES='\UF008E\UF007A\UF007B\UF007C\UF007D\UF007E\UF007F\UF0080\UF0081\UF0082\UF0079'
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # Values the newer preset changes or drops.
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.bzr|.citc|.git|.hg|.node-version|.python-version|.go-version|.ruby-version|.lua-version|.java-version|.perl-version|.php-version|.tool-versions|.shorten_folder_marker|.svn|.terraform|CVS|Cargo.toml|composer.json|go.mod|package.json|stack.yaml)'
  typeset -g POWERLEVEL9K_TERRAFORM_VERSION_SHOW_ON_COMMAND='terraform|tf'
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|cdk|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_SHOW_ON_COMMAND='terraform|pulumi|terragrunt'
  unset POWERLEVEL9K_YAZI_FOREGROUND POWERLEVEL9K_YAZI_BACKGROUND

  (( ! $+functions[p10k] )) || p10k reload
}

# The preset set this to its own path; `p10k configure` writes to it.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'

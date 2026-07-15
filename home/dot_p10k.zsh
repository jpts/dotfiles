# jpts' custom Powerlevel10k config, with similar style
# to Pure (https://github.com/sindresorhus/pure)

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Prompt colors.
  local grey='242'
  local lightgrey='247'
  local red='#FF5C57'
  local yellow='#F3F99D'
  local blue='#57C7FF'
  local magenta='#FF6AC1'
  local cyan='#9AEDFE'
  local white='#F1F1F0'

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                       # current directory
    vcs                       # git status
    prompt_char               # prompt symbol
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    command_execution_time    # previous command duration
    background_jobs
    virtualenv                # python virtual environment
    context                   # user@host
    nix_shell
    terraform
    aws
    azure
    gcloud
    kubecontext
    chezmoi_shell
  )

  ### general ###

  # Defines character set used by powerlevel10k.
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  # When set to `moderate`, some icons will have an extra space after them. This is meant to avoid
  # icon overlap when using non-monospace fonts. When set to `none`, spaces are not added.
  typeset -g POWERLEVEL9K_ICON_PADDING=none

  # Basic style options that define the overall prompt look.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt except the first. This doesn't emulate the bug
  # in Pure that makes prompt drift down whenever you use the Alt-C binding from fzf or similar.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # Magenta prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=$magenta
  # Red prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$red
  # Default prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  # Prompt symbol in command vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  # Prompt symbol in visual vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❮'
  # Prompt symbol in overwrite vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=false

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

### virtualenv ###

  # Grey Python Virtual Environment.
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$grey
  # Don't show Python version.
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  ### context ###

  # Context format when root: user@host. The first part red, the rest grey.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE="%F{$red}%n%f%F{$lightgrey}@%m%f"
  # Context format when not root: user@host. The whole thing grey.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE="%F{$lightgrey}%m%f"
  # Don't show context unless root or in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  ### command_execution_time ###

  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  # Don't show fractional seconds. Thus, 7s rather than 7.3s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Yellow previous command duration.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$yellow

  ### vcs ###

  # Grey Git prompt. This makes stale prompts indistinguishable from up-to-date ones.
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$grey

  # Disable async loading indicator to make directories that aren't Git repositories
  # indistinguishable from large Git repositories without known state.
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

  # Don't wait for Git status even for a millisecond, so that prompt always updates
  # asynchronously when Git state changes.
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0

  # Cyan ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND=$cyan
  # Don't show remote branch, current tag or stashes.
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind)
  # Don't show the branch icon.
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  # When in detached HEAD state, show @commit where branch normally goes.
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  # Don't show staged, unstaged, untracked indicators.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED}_ICON=
  # Show '*' when there are staged, unstaged or untracked files.
  typeset -g POWERLEVEL9K_VCS_DIRTY_ICON='*'
  # Show '⇣' if local branch is behind remote.
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=':⇣'
  # Show '⇡' if local branch is ahead of remote.
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=':⇡'
  # Don't show the number of commits next to the ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=1
  # Remove space between '⇣' and '⇡' and all trailing spaces.
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${${${P9K_CONTENT/⇣* :⇡/⇣⇡}// }//:/ }'

  # shorten branch name
  typeset -g POWERLEVEL9K_VCS_SHORTEN_LENGTH=17
  typeset -g POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=32
  typeset -g POWERLEVEL9K_VCS_SHORTEN_STRATEGY=truncate_from_right

  ### dir ###

  # Default current directory color.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
  # If directory is too long, shorten some of its segments to the shortest possible unique
  # prefix. The shortened directory can be tab-completed to the original.
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  # Replace removed segment suffixes with this symbol.
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  # Color of the shortened directory segments.
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
  # Color of the anchor directory segments. Anchor segments are never shortened. The first
  # segment is always an anchor.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  # Display anchor directory segments in bold.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # Don't shorten directories that contain any of these files. They are anchors.
  local anchor_files=(
    .git
    .hg
    .node-version
    .python-version
    .go-version
    .ruby-version
    .lua-version
    .java-version
    .perl-version
    .php-version
    .tool-version
    .svn
    .terraform
    Cargo.toml
    composer.json
    go.mod
    package.json
    stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  # If set to true, remove everything before the last (deepest) subdirectory that contains files
  # matching $POWERLEVEL9K_SHORTEN_FOLDER_MARKER. For example, when the current directory is
  # /foo/bar/git_repo/baz, prompt will display git_repo/baz. This assumes that /foo/bar/git_repo
  # contains a marker (.git) and other directories don't.
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  # Don't shorten this many last directory segments. They are anchors.
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  # Shorten directory if it's longer than this even if there is space for it. The value can
  # be either absolute (e.g., '80') or a percentage of terminal width (e.g, '50%'). If empty,
  # directory will be shortened only when prompt doesn't fit or when other parameters demand it
  # (see POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS and POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT below).
  # If set to `0`, directory will always be shortened to its minimum length.
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  # When `dir` segment is on the last prompt line, try to shorten it enough to leave at least this
  # many columns for typing commands.
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  # When `dir` segment is on the last prompt line, try to shorten it enough to leave at least
  # COLUMNS * POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT * 0.01 columns for typing commands.
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  # If set to true, embed a hyperlink into the directory. Useful for quickly
  # opening a directory in the file manager simply by clicking the link.
  # Can also be handy when the directory is shortened, as it allows you to see
  # the full directory that was used in previous commands.
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  # Enable special styling for non-writable directories.
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true
  # Show this icon when the current directory is not writable. POWERLEVEL9K_DIR_SHOW_WRITABLE
  # above must be set to true for this parameter to have effect.
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='∅'

  ### background_jobs ###

  # Don't show the number of background jobs.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  # Background jobs color.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=70

  ### nix-shell ###

  typeset -g POWERLEVEL9K_NIX_SHELL_CONTENT_EXPANSION='nix-shell($P9K_CONTENT)'
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=46
  #typeset -g POWERLEVEL9K_NIX_SHELL_VISUAL_IDENTIFIER_EXPANSION='󱄅' # needs nerdfonts

  ### terraform ###

  typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
    'prod-*'         PROD
    'integration-*'  TEST
    'test-*'         TEST
    '*'              OTHER)
  typeset -g POWERLEVEL9K_TERRAFORM_OTHER_FOREGROUND=38

  ### aws ###

  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AWS_CLASSES=(
    'prod-*'         PROD
    'integration-*'  TEST
    'test-*'         TEST
    '*'              DEFAULT)
  typeset -g POWERLEVEL9K_AWS_PROD_FOREGROUND=001
  typeset -g POWERLEVEL9K_AWS_TEST_FOREGROUND=220
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=208
  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'

  ## azure ###

  typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az'
  typeset -g POWERLEVEL9K_AZURE_CLASSES=(
    'prod-*'         PROD
    'integration-*'  TEST
    'test-*'         TEST
    '*'              OTHER)
  typeset -g POWERLEVEL9K_AZURE_PROD_FOREGROUND=001
  typeset -g POWERLEVEL9K_AZURE_TEST_FOREGROUND=220
  typeset -g POWERLEVEL9K_AZURE_OTHER_FOREGROUND=32

  ### gcp ###

  typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gcs|gsutil'
  typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=32
  typeset -g POWERLEVEL9K_GCLOUD_PARTIAL_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_ID//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_COMPLETE_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_NAME//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_REFRESH_PROJECT_NAME_SECONDS=60
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_CLASSES=(
    'prod-*'         PROD
    'integration-*'  TEST
    'test-*'         TEST
    '*'              DEFAULT)
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_PROD_FOREGROUND=001
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_TEST_FOREGROUND=220
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_FOREGROUND=32
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_CONTENT_EXPANSION='${P9K_GOOGLE_APP_CRED_PROJECT_ID//\%/%%}'

  ### k8s ###

  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|k|helm|kns'
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
    'prod-*'         PROD
    'integration-*'  TEST
    'test-*'         TEST
    '*'              DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_FOREGROUND=001
  typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_FOREGROUND=220
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=134
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'

  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'

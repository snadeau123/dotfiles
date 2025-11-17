# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


##### Core Zsh #####
export HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt AUTO_CD
autoload -Uz compinit && compinit

##### Shell-GPT integration ZSH v0.2 (Ctrl-L) #####
# ZLE widget that replaces the current command line with sgpt --shell output
_sgpt_zle() {
  if [[ -n $BUFFER ]]; then
    BUFFER=$(sgpt --shell <<< "$BUFFER" --no-interaction)
    CURSOR=${#BUFFER}
    zle redisplay
  fi
}
zle -N _sgpt_zle
# Bind Ctrl-L (overrides clear-screen); change if you prefer another key
bindkey '^L' _sgpt_zle

##### Cargo (Rust) #####
# Safe to source in Zsh
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

##### PATH tweaks ##### .local/bin is to make sure we have access to sgpt in a conda env
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

##### Prompt: user@host + (git branch) on line 1; pwd and [conda] on line 2 #####
# Git branch helper (short name or short hash)
_git_branch() {
  local b
  b=$(git symbolic-ref --short HEAD 2>/dev/null) || \
  b=$(git rev-parse --short HEAD 2>/dev/null) || return
  print -- " ($b)"
}

# Conda env helper
_conda_env() {
  [[ -n "$CONDA_DEFAULT_ENV" ]] || return
  print -- "[$CONDA_DEFAULT_ENV]"
}

# ---- Color palette ----
# Softer, readable tones with clear contrasts
local fg_user='%F{81}'        # cyan-blue for user@host
local fg_path='%F{39}'        # soft blue for path
local fg_git='%F{214}'        # amber/gold for git branch
local fg_env='%F{118}'        # light green for conda env
local fg_symbol='%F{245}'     # gray for separators and prompt symbol
local reset='%f'

# ---- Prompt formatting ----
# First line: user@host (git)
# Second line: path [env] $
PROMPT='${debian_chroot:+($debian_chroot)}'\
'${fg_user}%n@%m${reset} '\
'${fg_git}$(_git_branch)${reset}'$'\n'\
'${fg_path}%~${reset} '\
'${fg_symbol}➜ ${reset}'

# Optional right prompt: time
RPROMPT='%F{240}%*%f'

# ---- Window title (same behavior as before) ----
case "$TERM" in
  xterm*|rxvt*)
    precmd() { print -Pn '\e]0;%n@%m: %~\a' }
  ;;
esac



# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/snadeau/miniconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/snadeau/miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/snadeau/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/snadeau/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


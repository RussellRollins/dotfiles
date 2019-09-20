export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

source ~/bin/git-completion.bash

txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
bakgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
txtrst='\[\e[0m\]'    # Text Reset

# What this PS1 should end up looking like:
# 18:02:41 # atlas - git@(master) exited 130 $

function parse_time {
  curr="$(date '+%H:%M:%S')"
  echo "${txtpur}# ${curr} #${txtrst}"
}

function parse_path {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1 ; then
    git_repo="$(git rev-parse --show-toplevel)"
    git_name="$(basename $git_repo)"
    branch="$(git symbolic-ref HEAD 2>/dev/null)" || branch="(unnamed branch)"
    branch="${branch##refs/heads/}"
    echo "${txtblu}${git_name}${PWD##$git_repo}${txtrst} - ${txtgrn}git@(${branch})${txtrst}"
  elif [ "${PWD##$HOME}" != "${PWD}" ] ; then
    echo "${txtblu}~${PWD##$HOME}${txtrst}"
  else
    # If none of the special cases apply, just pwd
    echo "${txtblu}$(pwd)${txtrst}"
  fi
}

function parse_exit_code {
  code="$1"
  if [ "$code" -eq "0" ]; then
    echo "${txtgrn}exited ${code}${txtrst}"
  else
    echo "${txtred}exited ${code}${txtrst}"
  fi
}

PROMPT_COMMAND=__prompt_command
__prompt_command() {
  local EXIT="$?"

  PS1="$(parse_time) $(parse_path) - $(parse_exit_code $EXIT) $ "
}

export PATH="/usr/local/sbin:${HOME}/go/bin:${HOME}/bin/go/bin:${HOME}/bin:/usr/local/bin:${PATH}"
export GOPRIVATE="github.com/hashicorp"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
#!/bin/bash
#
# descr: this file is sourced via this repo's init.bash

__parse_script_arguments() {
    while (( "${#}" )); do
        case "${1}" in
            --operating-system|--os|-o)
                case "${2}" in
                    linux|windows|wsl) os="${2}"; shift ;;
                    *) echo "ERROR: unrecognized ${1} parameter ${2}" && return 1 ;;
                esac
                ;;
            *) echo "ERROR: arg ${1} is unexpected" && return 2 ;;
        esac
        shift
    done
}

_src(){
    #### default vars
    local os=''
    #### fill script vars with cmd line args and/or default values where applicable
    __parse_script_arguments "${@}" || return "1${?}"
    #### hardcoded values
    local path_this="${BASH_SOURCE[0]}"
    local dir_this="$(cd "$(dirname "${path_this}")"; pwd -P)" && [ "${dir_this}" != '' ] || ! __echo -se "ERROR: dir_this=''" || return 1
    local dir_repo="$(cd "${dir_this}" && cd $(git rev-parse --show-toplevel) && echo ${PWD})" && [ "${dir_repo}" != '' ] || ! __echo -se "ERROR: dir_repo=''" || return 1
    local dir_bin="${dir_repo}/bin"
    #### exports
    export GWSA="${dir_repo}"
    export PATH="${PATH}:${dir_bin}"
    #### cfg auto
    local open=''; case "${os}" in linux|wsl) open='xdg-open' ;; windows) open='start' ;; *) echo "ERROR: unable to set open var" && return 1;; esac
    local __git='git'; command -v git-number > /dev/null 2>&1 && __git='git-number' || ! echo 'WARNING: git-number cmd not found'
    #### includes
    . "${dir_this}/cfg.sh"
    #### funcs
    _cd_parent_aliases() { local ALS='.'; local DIR=''; for VAR in $(seq 1 "${1}") ; do ALS="${ALS}."; DIR="${DIR}../"; alias "${ALS}"'=cd '"${DIR}"; done }
    #### aliases
    ## git
    [ "${__git}" == 'git-number' ] && alias gn="${__git}" && alias gg='git -c color.status=always status -sb | head -n 1 && git-number -s' || alias gg='git status -sb'
    alias ga="${__git} add"
    alias gc="${__git} checkout"
    alias gr="${__git} reset"
    alias gd="${__git} diff"
    alias gf='git fetch'
    alias gp='git pull'
    alias grb='git rebase'
    alias gcp='git cherry-pick'
    alias gcm='git checkout master'
    alias grom='git fetch && git rebase origin/master'
    alias lg="git log --date=format:'%d-%m-%Y %H:%M' --pretty=format:'%h%x20%x20%Cred%ad%x20%x20%Cblue%an%x20%x20%Creset%s'"
    alias log="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n          %C(white)%s%C(reset)%n          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'"
    alias ggg='git submodule foreach git status -sb'
    alias gsu='git submodule update'
    alias gss='git submodule status'
    local git_completion="${dir_repo}/third-party/git/contrib/completion/git-completion.bash"
    if [ -f "${git_completion}" ]; then
        . "${git_completion}"
        __git_complete ga _git_add
        __git_complete gc _git_checkout
        __git_complete gr _git_reset
        __git_complete gd _git_diff
        # __git_complete gf _git_fetch
        # __git_complete gp _git_pull
        __git_complete grb _git_rebase
        __git_complete gcp _git_cherry-pick
        __git_complete gl _git_log
        __git_complete lg _git_log
        __git_complete log _git_log
    else
        echo 'WARNING: completion for git aliases failed'
    fi
    ## dirs
    _cd_parent_aliases '10'
    alias dl="cd ${HOME}/Downloads"
    alias dsk="cd ${HOME}/Desktop"
    alias doc="cd ${HOME}/Documents"
    alias gwsa="cd ${GWSA} && gg"
    ## misc
    alias op="${open}"
    alias rc="${editor} ${HOME}/.bashrc"
    alias rca="${editor} ${HOME}/.bash_aliases"
    alias rcg="${editor} ${path_this}"
    alias rcs="source ${HOME}/.bashrc"
    alias rcas="source ${HOME}/.bash_aliases"
    alias rcgs="source ${path_this}"
    [ "${os}" == 'windows' ] || alias sudo='sudo ' # purpose is to allow 'sudo <alias>'
    [ "${os}" == 'windows' ] && alias rs='clear' || rs="clear printf '\e[3j'"
}

_src "${@}" || exit "${?}"
#!/usr/bin/env zsh

local LAMBDA="%(?,%{$fg_bold[green]%}λ,%{$fg_bold[red]%}λ)"
if [[ "$USER" == "root" ]]; then USERCOLOR="red"; else USERCOLOR="yellow"; fi

function precmd_pipestatus() {
    local exit_status="${(j.|.)pipestatus}"
    local statuses="$(echo $exit_status | sed 's/|/ /g')"
    setopt shwordsplit
    for pipe_status in $statuses; do
        if [[ $pipe_status != 0 ]]; then
            echo -n "%{$fg_bold[red]%}${exit_status}"' '
        fi
    done
    unsetopt shwordsplit
    return 0
}

# Git sometimes goes into a detached head state. git_prompt_info doesn't
# return anything in this case. So wrap it in another function and check
# for an empty string.
function check_git_prompt_info() {
    exit_status="$(precmd_pipestatus)"
    if type git &>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
        if [[ -z $(_omz_git_prompt_info 2> /dev/null) ]]; then
            echo "%{$fg[blue]%}detached-head%{$reset_color%}) $(git_prompt_status)
%{$fg[yellow]%}${exit_status}➜ "
        else
            echo "$(_omz_git_prompt_info 2> /dev/null) $(git_prompt_status)
%{$fg_bold[cyan]%}${exit_status}➜ "
        fi
    else
        echo "%{$fg_bold[cyan]%}${exit_status}➜ "
    fi
}

function get_right_prompt() {
    if type git &>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
        echo -n "$(git_prompt_short_sha)%{$reset_color%}"
    else
        echo -n "%{$reset_color%}"
    fi
}

PROMPT=$'\n'$LAMBDA'\
 %{$fg_bold[$USERCOLOR]%}%n\
 %{$fg_no_bold[red]%}[%'${LAMBDA_MOD_N_DIR_LEVELS:-3}'~]\
 $(check_git_prompt_info)\
%{$reset_color%}'

RPROMPT='$(get_right_prompt)'

# Format for _omz_git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="at %{$fg[blue]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} ✔"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg_bold[white]%}^"


# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" %{$fg_bold[white]%}[%{$fg_bold[blue]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$fg_bold[white]%}]"

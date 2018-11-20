
# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar


# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'



############################## My private ################################
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rgrep='grep -nr --color=auto'



###################################
#### nice git/svn presentation ####
###################################

parse_git_branch() {
  local b=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  __branch=$b
  if [ -n "$b" ]; then
      #echo "(git::$b)" 
      #echo "(git::$b$(git_modified)$(git_commit_not_pushed))"
      #echo "(git::$b$(git_modified))"
      echo "($b$(git_modified))"
  fi
  unset __branch
}



parse_svn_branch() {
    parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk '{print "(svn::"$1")" }'
}
parse_svn_url() {
    svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}
parse_svn_repository_root() {
    svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}

git_modified() {
    local a=`git status -s --porcelain 2> /dev/null| grep "^\s*M"`
    if [ -n "$a" ]; then
        echo "*"
    fi
}

git_commit_not_pushed() {
    local a
    local rc
    if [ "$__branch" == "(no branch)" ]; then
        return
    fi
    # no remote branch
    if ! `git branch -r 2>/dev/null | grep -q $__branch` ; then
        echo "^^"
        return
    fi
    # commits not pushed
    a=`git log origin/$__branch..$__branch 2>/dev/null`
    rc=$?
    if [ "$rc" != 0 ] || [ -n "$a" ]; then
        echo "^"
    fi
}

#BLACK="\[\033[0;38m\]"
BLACK="\[\033[0;0m\]"
RED="\[\033[0;31m\]"
RED_BOLD="\[\033[01;31m\]"
BLUE="\[\033[01;94m\]"
GREEN="\[\033[0;32m\]"

if [ "$EUID" = 0 ]; then
    __first_color=$RED
else
    __first_color=$GREEN
fi
export PS1="$__first_color\u$GREEN@\h $RED_BOLD\w $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLUE\\$ $BLACK"
unset __first_color

###########################
#### convinient greps #####
###########################

# Grep thru the history
function ghistory () {
        declare regexp="${1}"

        history | /bin/grep --color=always \
                                --perl-regexp "${regexp}"

}

# find in c* /or h* files
function cfind() {
        declare exp="${1}"
        declare path="${2}"


        find "${path}" \( -name '*\.cpp' -o -name '*\.hxx' -o -name '*\.c' -o -name '*\.h' -o -name '*\.cxx' -o -name '*\.hpp' \) | xargs grep -in "${exp}"
}

#####################################
#### choose the coredump pattern ####
#####################################

mkdir -p /tmp/core_dumps

CUR_PAT="$(</proc/sys/kernel/core_pattern)"
PAT="/var/crash/core.%e.%p.%t"

if [ "$CUR_PAT" = "$PAT" ] ; then
  echo core dump pattern already set
else
  echo $PAT | sudo tee /proc/sys/kernel/core_pattern
fi

alias core_dumps="cd /var/crash/"


###########################
#### git config useful ####
###########################

# for the following alias you'll need thes git aliases.
# run __add_useful_git_alias once
__add_useful_git_alias () 
{
    echo adding git ll;
    git config --global alias.ll "log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    echo adding git branch-name;
    git config --global alias.branch-name '!git rev-parse --abbrev-ref HEAD';
    echo adding git publish;
    git config --global alias.publish '!git push -u origin $(git branch-name)';
    echo adding git publish-f;
    git config --global alias.publish-f '!git push -f -u origin $(git branch-name)';
    echo adding git unpublish;
    git config --global alias.unpublish '!git push origin :$(git branch-name)';
}

alias no_git_diff='git diff-index --quiet HEAD -- '
#push current branch to your origin after fixing format if needed
alias gpublish='if no_git_diff; then echo "no-diff"; git publish; else echo "theres a diff"; fi;' 

#push -f (will overwrite existing branch with the same name) current branch to your origin after fixing format if needed
alias gpublish-f='if no_git_diff; then echo "no-diff"; git publish-f; else echo "theres a diff"; fi;' 




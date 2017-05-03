#!/bin/bash

export GITAWAREPROMPT=~/.files/scripts/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"

# with uname -n
# export PS1="\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

#without uname -n
export PS1="\[\033[01;34m\]\w\[\033[00m\] \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "



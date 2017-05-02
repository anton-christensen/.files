export PATH=$PATH:/home/anton/.files/scripts

export GITAWAREPROMPT=~/.files/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"

# with uname -n
# export PS1="\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

#without uname -n
export PS1="\[\033[01;34m\]\w\[\033[00m\] \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

alias sshaau='ssh achri15@student.aau.dk@p3'
alias dont='dotnet'

alias netlist='netstat -tulpn'
alias gf='git fetch --all'
alias gs='git status'
alias gp='git pull'

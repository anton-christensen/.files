#!/bin/bash

alias shutdown='shutdown 0'
alias ls='ls -lh --color=auto'
alias ll='ls -lah'
alias nw='networkmanager_dmenu'

alias dont='dotnet'
alias salsa='alsamixer'

alias netlist='netstat -tulpn'

alias gf='git fetch --all --prune'
alias gs='git status'
alias gp='git pull'


alias spotify='spotify --force-device-scale-factor=2'

alias dockcomp='docker-compose'
docker-shell() {
    docker exec -it "$1" /bin/bash
}


export VISUAL="vim"

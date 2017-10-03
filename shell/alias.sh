#!/bin/bash

alias ls='ls --color=auto'
alias ll='ls -lah'
alias nw='networkmanager_dmenu'

alias dont='dotnet'

alias netlist='netstat -tulpn'

alias gf='git fetch --all'
alias gs='git status'
alias gp='git pull'

alias spotify='spotify --force-device-scale-factor=2'

docker-shell() {
    docker exec -it "$1" /bin/bash
}


export VISUAL="vim"

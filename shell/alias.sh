#!/bin/bash

alias shutdown='shutdown 0'
alias ls='ls -h --color=auto'
alias ll='ls -lah'
alias nw='networkmanager_dmenu'

alias dont='dotnet'
alias salsa='alsamixer'

alias netlist='netstat -tulpn'

alias gf='git fetch --all --prune'
alias gs='git status'
alias gp='git pull'

alias t="transmission-remote"

alias clip='xclip -sel c'
alias paste='xclip -sel c -o'

alias clipget="curl -s https://clipboard.antonchristensen.net 2>&1"
clipset() {
    if [ -z "$1" ]
    then
        _temp_cat=`cat`
        _std_in="$_temp_cat"
    else
        _std_in="$1"
    fi
    _std_in="clip=$_std_in"
    curl https://clipboard.antonchristensen.net --data-urlencode "$_std_in"
}

alias ppaste='paste | clipset'
alias cclip='clipget | clip'


alias spotify='spotify --force-device-scale-factor=2'

# alias sudo='echo "Johysv{{l<3" | sudo -S '

alias dockcomp='docker-compose'
docker-shell() {
    docker exec -it "$1" /bin/bash
}

alias docker-compose='! docker ps | grep -q "Cannot connect to the Docker daemon" && sudo systemctl start docker ; docker-compose '

alias c='pygmentize -g'

export VISUAL="vim"

export PS1="%F{red}%n%f@%F{blue}%M%f:%F{magenta}%B%~%b%f$ "
[[ $TMUX == "" ]] && tmux && exit

alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias ls='ls --color'


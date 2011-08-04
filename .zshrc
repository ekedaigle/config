# Detect the current platform
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
	platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
	platform='darwin'
fi

# Configure command prompt
export PS1="%F{red}%n%f@%F{blue}%M%f:%F{magenta}%B%~%b%f$ "
export EDITOR=vim

# Set up aliases
alias l='ls'
alias ll='ls -l'
alias la='ls -a'

if [[ "$platform" == 'darwin' ]]; then
	alias ls='ls -G'
	alias fr='/Applications/Firefox.app/Contents/MacOS/firefox-bin -P temp'
	alias gmail='~/Code/Scripts/unreadMail.bash'
elif [[ "$platform" == 'linux' ]]; then
	alias ls='ls --color=auto'
fi

# Set up PATH
export PATH=$PATH:/opt/git/bin:/opt/local/bin:/opt/local/sbin

if [[ "$platform" == 'darwin' ]]; then
	export PATH=$PATH:/Developer/usr/bin:~/Code/Scripts
fi

tmux attach || tmux new
clear

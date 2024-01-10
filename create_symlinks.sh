#!/bin/bash

base_dir=$(pwd)

mkdir -p ~/bin
ln -sfn "$base_dir/colorgcc/colorgcc.pl" ~/bin/gcc
ln -sfn "$base_dir/colorgcc/colorgcc.pl" ~/bin/g++
ln -sfn "$base_dir/colorgcc/colorgcc.pl" ~/bin/c++
ln -sfn "$base_dir/colorgcc/colorgcc.pl" ~/bin/cc
ln -sfn "$base_dir/clang-format" ~/.clang-format
ln -sfn "$base_dir/colorgcc/colorgcc" ~/.colorgccrc
ln -sfn "$base_dir/flake8" ~/.config/flake8
ln -sfn "$base_dir/git/gitconfig" ~/.gitconfig
ln -sfn "$base_dir/git/git_template" ~/.git_template
ln -sfn "$base_dir/tmux/tmux.conf" ~/.tmux.conf
ln -sfn "$base_dir/tmux/tmux_select_pane.sh" ~/bin/tmux_select_pane.sh
ln -sfn "$base_dir/tmux/tmux_at_edge.sh" ~/bin/tmux_at_edge.sh
ln -sfn "$base_dir/tmux/tmux-session-created" ~/bin/tmux-session-created
ln -sfn "$base_dir/tmux/tmux-session-closed" ~/bin/tmux-session-closed
ln -sfn "$base_dir/vim/vimrc" ~/.vimrc
ln -sfn "$base_dir/vim/vim" ~/.vim
mkdir -p ~/.config/nvim
ln -sfn "$base_dir/vim/vimrc" ~/.config/nvim/init.vim
ln -sfn "$base_dir/vim/vim" ~/.nvim
ln -sfn "$base_dir/zsh/oh-my-zsh" ~/.oh-my-zsh
ln -sfn "$base_dir/zsh/zshrc" ~/.zshrc
for filename in $base_dir/bin/*; do
    ln -sfn "$filename" ~/bin/"${filename##*/}"
done

if [ "$(uname)" = "Darwin" ]; then
    ln -sf "$base_dir/tmux/tmux-osx.conf" ~/.tmux-osx.conf
fi

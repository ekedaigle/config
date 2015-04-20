#!/bin/bash

base_dir=$(pwd)

echo -n "Creating links..."

mkdir -p ~/bin
ln -sf "$base_dir/colorgcc/colorgcc.pl" ~/bin/gcc
ln -sf "$base_dir/colorgcc/colorgcc.pl" ~/bin/g++
ln -sf "$base_dir/colorgcc/colorgcc.pl" ~/bin/c++
ln -sf "$base_dir/colorgcc/colorgcc.pl" ~/bin/cc
ln -sf "$base_dir/clang-format" ~/.clang-format
ln -sf "$base_dir/colorgcc/colorgcc" ~/.colorgccrc
ln -sf "$base_dir/git/gitconfig" ~/.gitconfig
ln -sf "$base_dir/tmux/tmux.conf" ~/.tmux.conf
ln -sf "$base_dir/vim/vimrc" ~/.vimrc
ln -sf "$base_dir/vim/vim" ~/.vim
ln -sf "$base_dir/vim/vimrc" ~/.nvimrc
ln -sf "$base_dir/vim/vim" ~/.nvim
ln -sf "$base_dir/zsh/oh-my-zsh" ~/.oh-my-zsh
ln -sf "$base_dir/zsh/zshrc" ~/.zshrc
echo "done"

git submodule update --init

if [ $? -ne 0 ]; then
	echo "Failed to update submodules"
	exit 1
fi

PKG_CONFIG_PATH=~/lib/pkgconfig:$PKG_CONFIG_PATH
LIBRARY_PATH=~/lib:$LIBRARY_PATH
LD_LIBRARY_PATH=~/lib:$LD_LIBRARY_PATH
PATH=~/bin:$PATH

command -v tmux >/dev/null 2>&1 || {
	echo "tmux not found, installing"

	pkg-config --exists libevent && {
		echo "installing libevent"
		wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
		tar -xf libevent-2.0.21-stable.tar.gz
		rm -rf libevent-2.0.21-stable.tar.gz
		cd libevent-2.0.21-stable

		./configure --prefix=$HOME || {
			echo "libevent configure failed"
			exit 1
        }

		make || {
			echo "libevent build failed"
			exit 1
        }

		make install || {
			echo "libevent install failed"
			exit 1
        }
		
		rm -rf libevent-2.0.21-stable
		cd $base_dir
    }

	wget http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.8/tmux-1.8.tar.gz || {
		echo "Failed to download tmux"
		exit 1
    }
	
	tar -xf tmux-1.8.tar.gz
	rm -rf tmux-1.8.tar.gz
	cd tmux-1.8

	./configure --prefix=$HOME || {
		echo "Failed to configure tmux"
		exit 1
    }

	make || {
		echo "Failed to build tmux"
		exit 1
    }

	make install || {
		echo "Failed to install tmux"
		exit 1
    }

	cd $base_dir
	rm -rf tmux-1.8
}

command -v zsh >/dev/null 2>&1 || {
	echo "zsh not found, installing"
	
	wget http://downloads.sourceforge.net/project/zsh/zsh/5.0.2/zsh-5.0.2.tar.gz || {
		echo "Error downloading zsh"
		exit 1
    }

	tar -xf zsh-5.0.2.tar.gz
	rm -rf zsh-5.0.2.tar.gz
	cd zsh-5.0.2

	./configure --prefix=$HOME || {
		echo "zsh configure failed"
		exit 1
    }

	make || {
        echo "zsh build failed"
        exit 1
    }

	make install || {
		echo "zsh install failed"
		exit 1
    }
	
	cd $base_dir
	rm -rf zsh-5.0.2
}

cd $base_dir

vim +PluginInstall +qall

cd $base_dir/vim/vim/bundle/YouCompleteMe

if [ ! -f third_party/ycmd/ycm_client_support.so ] || [ ! -f third_party/ycmd/ycm_core.so ]; then
    ./install.sh --clang-completer || {
        echo "YouCompleteMe build failed"
        exit 1
    }
fi

# hack for Arch/CentOS where libedit.so.2 does not exist
cd $base_dir/vim/vim/bundle/YouCompleteMe/third_party/ycmd

if [[ $(ldd libclang.so | grep libedit.so) == *"not found" ]]; then
    ln -s /usr/lib64/libedit.so.0 libedit.so.2
fi

command -v pip >/dev/null 2>&1 || {
    echo "pip not found, installing"

    wget https://bootstrap.pypa.io/get-pip.py || {
        echo "Downloading pip bootstrap script failed"
        exit 1
    }

    sudo -E python get-pip.py || {
        echo "pip install failed"
        exit 1
    }
}

command -v nvim >/dev/null 2>&1 || {
    cd $base_dir/neovim
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH=$HOME" install
    sudo -E pip install neovim
}

command -v cowsay -h > /dev/null 2>&1 || {
    command -v brew > /dev/null 2>&1 && {
        brew install cowsay
    }

    command -v yum > /dev/null 2>&1 && {
        sudo yum install cowsay
    }

    command -v apt-get > /dev/null 2>&1 && {
        sudo apt-get install cowsay
    }
}


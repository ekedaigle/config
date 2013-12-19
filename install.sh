#!/bin/bash

base_dir=$(pwd)

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

	pkg-config --exists libevent

	if [ $? -ne 0 ]; then
		echo "installing libevent"
		wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
		tar -xf libevent-2.0.21-stable.tar.gz
		rm -rf libevent-2.0.21-stable.tar.gz
		cd libevent-2.0.21-stable
		./configure --prefix=$HOME
		
		if [ $? -ne 0 ]; then
			echo "libevent configure failed"
			exit 1
		fi

		make
	
		if [ $? -ne 0 ]; then
			echo "libevent build failed"
			exit 1
		fi

		make install
	
		if [ $? -ne 0 ]; then
			echo "libevent install failed"
			exit 1
		fi
		
		rm -rf libevent-2.0.21-stable
		cd $base_dir
	fi

	wget http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.8/tmux-1.8.tar.gz

	if [ $? -ne 0 ]; then
		echo "Failed to download tmux"
		exit 1
	fi
	
	tar -xf tmux-1.8.tar.gz
	rm -rf tmux-1.8.tar.gz
	cd tmux-1.8
	./configure --prefix=$HOME

	if [ $? -ne 0 ]; then
		echo "Failed to configure tmux"
		exit 1
	fi
	
	make

	if [ $? -ne 0 ]; then
		echo "Failed to build tmux"
		exit 1
	fi

	make install

	if [ $? -ne 0 ]; then
		echo "Failed to install tmux"
		exit 1
	fi

	cd $base_dir
	rm -rf tmux-1.8
}

command -v zsh >/dev/null 2>&1 || {
	echo "zsh not found, installing"
	
	wget http://downloads.sourceforge.net/project/zsh/zsh/5.0.2/zsh-5.0.2.tar.gz
	
	if [ $? -ne 0 ]; then
		echo "Error downloading zsh"
		exit 1
	fi

	tar -xf zsh-5.0.2.tar.gz
	rm -rf zsh-5.0.2.tar.gz
	cd zsh-5.0.2
	./configure --prefix=$HOME

	if [ $? -ne 0 ]; then
		echo "zsh configure failed"
		exit 1
	fi

	make

	if [ $? -ne 0 ]; then
		echo "zsh build failed"
		exit 1
	fi

	make install

	if [ $? -ne 0 ]; then
		echo "zsh install failed"
		exit 1
	fi
	
	cd $base_dir
	rm -rf zsh-5.0.2
}

# Download, build and install clang

if [ ! -d llvm ]; then
	git clone http://llvm.org/git/llvm.git

	if [ $? -ne 0 ]; then
		echo "Failed to download LLVM"
		exit 1
	fi
fi

if [ ! -d llvm/tools/clang ]; then
	cd llvm/tools
	git clone http://llvm.org/git/clang.git

	if [ $? -ne 0 ]; then
		echo "Failed to download clang"
		exit 1
	fi
	
	cd $base_dir
fi

if [ ! -d llvm/projects/compiler-rt ]; then
	cd llvm/projects
	git clone http://llvm.org/git/compiler-rt.git

	if [ $? -ne 0 ]; then
		echo "Failed to download compiler-rt"
		exit 1
	fi

	cd base_dir
fi

cd $base_dir

if [ ! -e llvm-build/Release+Asserts/bin/clang-format ] || [ ! -e llvm-build/Release+Asserts/lib/libclang.so ]; then
	mkdir llvm-build
	cd llvm-build
	../llvm/configure --enable-optimized

	if [ $? -ne 0 ]; then
		echo "Failed to configure LLVM"
		exit 1
	fi

	make

	if [ $? -ne 0 ]; then
		echo "Failed to build LLVM"
		exit 1
	fi
fi

cd $base_dir
cd vim/vim/bundle/YouCompleteMe
git submodule update --init --recursive

if [ $? -ne 0 ]; then
	echo "Failed to update YouCompleteMe submodules"
	exit 1
fi

mkdir ycm-build
cd ycm-build

cmake -G "Unix Makefiles" -DEXTERNAL_LIBCLANG_PATH=$base_dir/llvm-build/Release+Asserts/lib/libclang.so . ../cpp

if [ $? -ne 0 ]; then
	echo "YouCompleteMe cmake failed"
	exit 1
fi

make ycm_support_libs

if [ $? -ne 0 ]; then
	echo "YouCompleteMe build failed"
fi

cd $base_dir

echo -n "Creating links..."
ln -s clang-format ~/.clang-format
ln -s colorgcc/colorgcc ~/.colorgcc
ln -s git/gitconfig ~/.gitconfig
ln -s tmux/tmux.conf ~/.tmux.conf
ln -s vim/vimrc ~/.vimrc
ln -s vim/vim ~/.vim
ln -s zsh/oh-my-zsh ~/.oh-my-zsh
ln -s zsh/zshrc ~/.zshrc
echo "done"

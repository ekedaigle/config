LINKS = {
        'colorgcc/colorgccrc' : '.colorgccrc',
        'git/gitconfig' : '.gitconfig',
        'tmux/tmux.conf' : '.tmux.conf',
        'vim/vim' : '.vim',
        'vim/vimrc' : '.vimrc',
        'zsh/oh-my-zsh' : '.oh-my-zsh',
        'zsh/zshrc' : '.zshrc'
}

def create_link(file_path, link_path):
    print file_path, link_path
    if os.path.exists(link_path):
        answer = raw_input('Override path %s? (y/N)' % link_path)

        if not answer in ['y', 'Y', 'yes', 'Yes']:
            return False

    success = True
    try:
        os.symlink(file_path, link_path)
    except OSError:
        success = False
    
    return success

def create_all_links(base_dir):
    for source, dest in LINKS.iteritems():
        print 'Linking %s --> %s' % (source, dest)
        if not create_link(base_dir + source, os.path.expanduser('~/' + dest)):
            print 'Error'

if __name__ == '__main__':
    import sys, os

    if os.path.isabs(sys.argv[0]):
        config_dir = os.path.dirname(sys.argv[0])
    else:
        config_dir = os.getcwd() + '/' + os.path.dirname(sys.argv[0])
    
    create_all_links(config_dir)

def create_link(file_path, link_path):
	success = True

	try:
		os.symlink(file_path, link_path)
	except OSError:
		success = False
	
	return success

if __name__ == '__main__':
	import sys, os

	if os.path.isabs(sys.argv[0]):
		config_dir = os.path.dirname(sys.argv[0])
	else:
		config_dir = os.getcwd() + '/' + os.path.dirname(sys.argv[0])
	
	for d in os.listdir(config_dir):
		dir_path = config_dir + '/' + d

		if not os.path.isdir(dir_path):
			continue

		if d[0] == '.':
			continue

		for f in os.listdir(dir_path):
			file_path = dir_path + '/' + f
			link_path = os.path.expanduser('~/.' + f)
			print 'Linking', file_path, 'to', link_path


			if not create_link(file_path, link_path):
				print 'File', f, 'already exists. Replace? (Y/n)',
				ch = raw_input()

				if ch == 'n' or ch == 'N':
					print 'Skipping', f
				else:
					os.remove(link_path)
					create_link(file_path, link_path)


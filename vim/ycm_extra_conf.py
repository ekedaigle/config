#!/usr/bin/env python
#
# Copyright (C) 2014  Google Inc.
#
# This file is part of YouCompleteMe.
#
# YouCompleteMe is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# YouCompleteMe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with YouCompleteMe.  If not, see <http://www.gnu.org/licenses/>.

import os
import struct
import ycm_core

# These are the compilation flags that will be used in case there's no
# compilation database set (by default, one is not set).
# CHANGE THIS LIST OF FLAGS. YES, THIS IS THE DROID YOU HAVE BEEN LOOKING FOR.
flags = [
'-Wall',
'-Wextra',
'-DNDEBUG',
'-std=c++11',
'-x',
'c++',
'-isystem',
'/usr/include',
'-isystem',
'/usr/local/include'
]


# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags.
compilation_database_folder = os.path.abspath('build')

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

CXX_EXTENSIONS = ('.C', '.cc', '.cpp', '.CPP', '.c++', '.cp', '.cxx')
OBJC_EXTENSIONS = ('.m', '.mm')
C_EXTENSIONS = ('.c',)
SOURCE_EXTENSIONS = CXX_EXTENSIONS + OBJC_EXTENSIONS + C_EXTENSIONS

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]

def IsSourceFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in SOURCE_EXTENSIONS

def FindSourceFile( text ):
    for filename in (t.strip(' \\') for t in text.splitlines()):
        if filename.endswith(SOURCE_EXTENSIONS):
            return filename

    return None

def FindHeaderFileSourceNinja(filename, f):
    filename = os.path.relpath(filename, compilation_database_folder)
    if f.read(12) != '# ninjadeps\n':
        return None

    f.read(4) # ignore version

    paths = []

    while True:
        length_s = f.read(4)

        if length_s == '':
            break

        length = struct.unpack('I', length_s)[0]

        if length < 0x80000000: # path record
            name = f.read(length - 4).rstrip('\x00')
            paths.append(name)
            f.read(4) # ignore
        else: # dependency record
            length -= 0x80000000
            out_id = struct.unpack('I', f.read(4))[0]
            f.read(4) # ignore time
            length -= 8
            in_ids = struct.unpack('I' * (length / 4), f.read(length))

            if filename in [paths[in_id] for in_id in in_ids]:
                c_files = [paths[in_id] for in_id in in_ids if IsSourceFile(paths[in_id])]

                if len(c_files) > 0:
                    return os.path.normpath(os.path.join(compilation_database_folder, c_files[0]))

def FindHeaderFileSource( filename ):
    # first try to find a ninja deps file
    try:
        with open(os.path.join(compilation_database_folder, '.ninja_deps')) as f:
            r = FindHeaderFileSourceNinja(filename, f)

            if not r is None:
                return r
    except IOError:
        pass

    with open(os.path.join(compilation_database_folder, 'CMakeFiles', 'TargetDirectories.txt'), 'r') as targets:
        for line in targets:
            for root, dirs, files in os.walk(line.strip()):
                for f in files:
                    if f.endswith('.d'):
                        with open(os.path.join(root, f)) as dep_file:
                            text = dep_file.read()
                            if filename in text:
                                return FindSourceFile(text)

    return None

def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    replacement = FindHeaderFileSource(filename)
    if replacement is not None and os.path.exists(replacement):
        compilation_info = database.GetCompilationInfoForFile(replacement)

        if compilation_info.compiler_flags_:
            if replacement.endswith(CXX_EXTENSIONS):
                compilation_info.compiler_flags_.append('-x')
                compilation_info.compiler_flags_.append('c++')

            return compilation_info

    return None

  return database.GetCompilationInfoForFile( filename )


# This is the entry point; this function is called by ycmd to produce flags for
# a file.
def FlagsForFile( filename, **kwargs ):
  if database:
    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object
    compilation_info = GetCompilationInfoForFile( filename )
    if not compilation_info:
        return { 'flags' : flags, 'do_cache' : True }

    final_flags = MakeRelativePathsInFlagsAbsolute(
      compilation_info.compiler_flags_,
      compilation_info.compiler_working_dir_ )
  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )

  return {
    'flags': final_flags,
    'do_cache': True
  }


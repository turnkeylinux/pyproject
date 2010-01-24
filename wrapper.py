#!/usr/bin/python
"""
Execution wrapper.

What it does is:
1) Adds PATH_LIBEXEC to the PATH environment.
2) Proxies execution to the specified command.

This hides the various executable components behind a single tool.
"""

import sys
import os
import imp
import version

COPYRIGHT="version v%d.%d (c) 2009 TurnKey Linux - all rights reserved" % (version.major, version.minor)

# location of our python modules
PATH_LIB="pylib"

# location of our executables (relative to the install path)
PATH_LIBEXEC="libexec"

# what commands are available (they must be prefixed with cmd_ in PATH_LIB)
commands = ['prog', 'prog2']

def setup_env(path_install):
    if PATH_LIBEXEC:
        path_orig = os.getenv('PATH')
        path_libexec = os.path.join(path_install, PATH_LIBEXEC)
        os.putenv('PATH', ':'.join([path_libexec, path_orig]))

def get_av0():
    try:
        cmdline = file("/proc/%d/cmdline" % os.getpid(), "r").read()
        return cmdline.split("\x00")[0]
    except:
        return sys.argv[0]

def usage(error=None):
    print >> sys.stderr, COPYRIGHT
    if error:
        print >> sys.stderr, "error: " + error
    print >> sys.stderr, """Syntax: %s [ --help ] command [args]
Commands:""" % os.path.basename(get_av0())
    for command in commands:
        print >> sys.stderr, "    %s" % command
    sys.exit(1)
    
def main():
    path_install = os.path.dirname(__file__)

    path_pythonlib = os.path.join(path_install, PATH_LIB)
    sys.path.insert(0, path_pythonlib)
    
    setup_env(path_install)

    if len(commands) > 1:
        if len(sys.argv) < 2 or sys.argv[1] == "--help":
            usage()

        command = sys.argv[1]
        if not commands.count(command):
            usage("no such command '%s'" % command)

        args = sys.argv[2:]
    else:
        command = commands[0]
        args = sys.argv[1:]
        
    module_name = "cmd_" + command.replace("-", "_")
    module_args = imp.find_module(module_name, [ path_pythonlib ])
    module = imp.load_module(module_name, *module_args)

    sys.argv = [ get_av0() ] + args
    module.main()

if __name__=='__main__':
    main()

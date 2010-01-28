#!/usr/bin/python
"""
Execution wrapper.

What it does is:
1) Adds PATH_LIBEXEC to the PATH environment.
2) Proxies execution to the specified command.

This hides the various executable components behind a single tool.
"""

import re
import sys
import os
import imp
import version

COPYRIGHT="version v%d.%d (c) 2009 TurnKey Linux - all rights reserved" % (version.major, version.minor)

# location of our python modules
PATH_LIB="pylib"

# location of our executables (relative to the install path)
PATH_LIBEXEC="libexec"

def setup_env(path_install):
    if PATH_LIBEXEC:
        path_orig = os.getenv('PATH')
        path_libexec = os.path.join(path_install, PATH_LIBEXEC)
        os.putenv('PATH', ':'.join([path_libexec, path_orig]))

# this function is designed to work when running in-place source
# and when running code through a pycompiled installation with execproxy
def get_av0():
    try:
        cmdline = file("/proc/%d/cmdline" % os.getpid(), "r").read()
        args = cmdline.split("\x00")
        if re.match(r'python[\d\.]*$', os.path.basename(args[0])):
            av0 = args[1]
        else:
            av0 = args[0]
                    
    except IOError:
        av0 = sys.argv[0]

    return os.path.basename(av0)

def usage(error=None):
    
    print >> sys.stderr, COPYRIGHT
    if error:
        print >> sys.stderr, "error: " + error
    print >> sys.stderr, """Syntax: %s [ --help ] command [args]
Commands:""" % os.path.basename(get_av0())
    for command in commands:
        print >> sys.stderr, "    %s" % command
    sys.exit(1)
    
def get_main_commands(path):
    k = {}
    for file in os.listdir(path):
        m = re.match(r'^cmd_(.*)\.py[co]?$', file)
        if not m:
            continue
        command = m.group(1)
        command = command.replace("_", "-")
        k[command] = True
    commands = k.keys()
    commands.sort()
    
    return commands

def main():
    path_install = os.path.dirname(__file__)
    path_pythonlib = os.path.join(path_install, PATH_LIB)

    global commands
    commands = get_main_commands(path_pythonlib)

    sys.path.insert(0, path_pythonlib)
    setup_env(path_install)

    if len(commands) > 1:
        av0 = get_av0()

        # project-command? (symbolic link)
        try:
            command = av0[av0.index('-') + 1:]
            args = sys.argv[1:]
        except ValueError:
            if len(sys.argv) < 2 or sys.argv[1] == "--help":
                usage()

            command = sys.argv[1]
            args = sys.argv[2:]

        if not commands.count(command):
            usage("no such command '%s'" % command)

    else:
        command = commands[0]
        args = sys.argv[1:]
        
    module_name = "cmd_" + command.replace("-", "_")
    module_args = imp.find_module(module_name, [ path_pythonlib ])
    module = imp.load_module(module_name, *module_args)

    sys.argv = [ command ] + args
    module.main()

if __name__=='__main__':
    main()

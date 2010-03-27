#!/usr/bin/python
# Copyright (c) 2010 TurnKey Linux - all rights reserved
"""Python project skeleton
"""

import re
import sys
import os
import imp
import version

COPYRIGHT="version v%d.%d (c) 2010 TurnKey Linux - all rights reserved" % (version.major, version.minor)

# location of our python modules
PATH_LIB="pylib"

# location of our executables (relative to the install path)
PATH_LIBEXEC="libexec"

# this variable allows you to optionally specify the order commands
# are printed in Commands.usage()
COMMANDS_USAGE_ORDER = []

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

class Commands:
    class Command:
        def __init__(self, name, module):
            self.name = name
            self.module = module
            self.desc = ""
            self.doc = ""
            
            doc = module.__doc__
            if doc:
                self.doc = doc.strip()
                self.desc = self.doc.split('\n')[0]
            
    def _find_commands(self):
        commands = set()
        for file in os.listdir(self.path):
            m = re.match(r'^cmd_(.*)\.py[co]?$', file)
            if not m:
                continue
            command = m.group(1)
            command = command.replace("_", "-")

            commands.add(command)

        return commands

    def _get_module(self, command_name):
        module_name = "cmd_" + command_name.replace("-", "_")
        module_args = imp.find_module(module_name, [ self.path ])
        module = imp.load_module(module_name, *module_args)

        return module

    def __init__(self, path):
        self.path = path
        self.commands = {}

        for command_name in self._find_commands():
            module = self._get_module(command_name)
            self.commands[command_name] = self.Command(command_name, module)
    
    def usage(self, error=None):
        print >> sys.stderr, COPYRIGHT
        if error:
            print >> sys.stderr, "error: " + error
           
        print >> sys.stderr, "Syntax: %s <command> [args]" % os.path.basename(get_av0())
        if __doc__:
            print __doc__
        print >> sys.stderr, "Commands:"
        def print_command(name):
            command = self.commands.get(name)
            if command:
                print >> sys.stderr, "    %s    %s" % (command.name.ljust(maxlen),
                                                       command.desc)
        command_names = self.get_names()
        maxlen = max([len(name) for name in command_names])
        for name in COMMANDS_USAGE_ORDER:
            if name == '':
                print
                continue
            print_command(name)

        command_names = list(set(command_names) - set(COMMANDS_USAGE_ORDER))
        command_names.sort()
        for name in command_names:
            print_command(name)
            
        sys.exit(1)

    def get(self, name):
        return self.commands.get(name)

    def get_names(self):
        return self.commands.keys()

    def exists(self, name):
        return self.commands.has_key(name)

    def run(self, name, args):
        sys.argv = [ name ] + args
        command = self.get(name)
        if '-h' in args or '--help' in args:
            try:
                command.module.usage()
            except AttributeError:
                print >> sys.stderr, "error: no help for " + name
                sys.exit(1)
            
        command.module.main()
        
    def __len__(self):
        return len(self.commands)
    
def main():
    install_path = os.path.dirname(__file__)
    if PATH_LIBEXEC:
        os.environ['PATH'] = os.path.join(install_path, PATH_LIBEXEC) + ":" + \
                             os.environ['PATH']
    
    pylib_path = os.path.join(install_path, PATH_LIB)
    sys.path.insert(0, pylib_path)

    commands = Commands(pylib_path)

    if len(commands) > 1:
        av0 = get_av0()

        # project-name? (symbolic link)
        try:
            name = av0[av0.index('-') + 1:]
            args = sys.argv[1:]
        except ValueError:
            if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
                commands.usage()

            name = sys.argv[1]
            args = sys.argv[2:]

        if not commands.exists(name):
            commands.usage("no such name '%s'" % name)

    else:
        name = commands.get_names()[0]
        args = sys.argv[1:]

    commands.run(name, args)
    
if __name__=='__main__':
    main()

# Copyright (c) TurnKey Linux - http://www.turnkeylinux.org
#
# This file is part of pyproject
#
# pyproject is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.

import os
from os.path import *

import re
import sys
import imp
import getopt
from executil import getoutput, ExecError

# fool import machinery into treating us like a package
__path__ = []

class ModuleLoader:
    def __init__(self, path, module_args):
        self.path = path
        self.module_args = module_args

    def load_module(self, fullname):
        if fullname in sys.modules:
            return sys.modules[fullname]

        if self.module_args:
            orig_path = os.getcwd()
            os.chdir(self.path)
            try:
                module = imp.load_module(fullname, *self.module_args)
            finally:
                os.chdir(orig_path)
        else:
            # create an empty package
            # this is a hack needed to resolve heirarchical imports
            module = imp.new_module(fullname)
            module.__file__ = self.path
            module.__path__ = [self.path]

        sys.modules[fullname] = module
        return module

class ImportHook:
    @staticmethod
    def _get_project_paths(conf_file='/etc/pyproject.conf'):
        default_paths = ['/usr/local/lib', '/usr/lib']
        paths = []

        if not exists(conf_file):
            return default_paths

        for line in file(conf_file).readlines():
            line = line.strip()

            if not line or line.startswith("#"):
                continue

            op, val = re.split(r'\s+', line, 1)
            if op == 'project_path':
                paths.append(val)

        paths.extend(default_paths)
        return paths

    @staticmethod
    def _find_project_path(name):
        project_paths = ImportHook._get_project_paths()
        for prefix in project_paths:
            path = join(prefix, name, 'pylib')
            if exists(path):
                return path

        return None

    @staticmethod
    def find_module(fullname, path=None):
        parts = fullname.split('.')
        if parts[0] != __name__:
            return None

        if len(parts) not in (2,3):
            return None

        pyproject_path = ImportHook._find_project_path(parts[1])
        if not pyproject_path:
            return None

        module_args = None
        if len(parts) > 2:
            try:
                module_args = imp.find_module(parts[2], [ pyproject_path ])
            except ImportError:
                return None

        return ModuleLoader(pyproject_path, module_args)

if ImportHook not in sys.meta_path:
    sys.meta_path.append(ImportHook)

def fatal(e):
    print >> sys.stderr, "fatal: " + str(e)
    sys.exit(1)

# this function is designed to work when running in-place source
# and when running code through a pycompiled installation with execproxy
def get_av0():
    try:
        cmdline = file("/proc/%d/cmdline" % os.getpid(), "r").read()
        args = cmdline.split("\x00")
        if re.match(r'python[\d\.]*$', basename(args[0])):
            av0 = args[1]
        else:
            av0 = args[0]

    except IOError:
        av0 = sys.argv[0]

    return basename(av0)

class _Commands:
    class Error(Exception):
        pass

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

    def __init__(self, path, cli_wrapper):
        self.cli_wrapper = cli_wrapper
        self.path = path
        self.commands = {}
        self.use_debugger = False
        self.use_profiler = False

        for command_name in self._find_commands():
            module = self._get_module(command_name)
            self.commands[command_name] = self.Command(command_name, module)

        # if there's only one command, patch its usage to show copyright
        if len(self.commands) == 1:
            command = self.commands.values()[0]
            module = command.module
            usage = getattr(module, "usage", None)
            if usage:
                def wrapper(*args):
                    print >> sys.stderr, self.cli_wrapper.get_copyright()
                    return usage(*args)
                module.usage = wrapper

    def usage(self, error=None):
        print >> sys.stderr, self.cli_wrapper.get_copyright()
        if error:
            print >> sys.stderr, "error: " + str(error)

        print >> sys.stderr, "Syntax: %s <command> [args]" % basename(get_av0())
        if self.cli_wrapper.DESCRIPTION:
            print self.cli_wrapper.DESCRIPTION.strip() + "\n"
        print >> sys.stderr, "Commands:"
        def print_command(name):
            command = self.commands.get(name)
            if command:
                print >> sys.stderr, "    %s    %s" % (command.name.ljust(maxlen),
                                                       command.desc)
        command_names = self.get_names()
        maxlen = max([len(name) for name in command_names])
        for name in self.cli_wrapper.COMMANDS_USAGE_ORDER:
            if name == '':
                print
                continue
            print_command(name)

        command_names = list(set(command_names) - set(self.cli_wrapper.COMMANDS_USAGE_ORDER))
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

    def _pre_run(self, name, args):
        sys.argv = [ name ] + args
        command = self.get(name)

        i = 1
        while i < len(sys.argv):
            if sys.argv[i] == "--profile":
                self.use_profiler = True
                del sys.argv[i]
            elif sys.argv[i] == "--debug":
                self.use_debugger = True
                del sys.argv[i]
            else:
                i += 1

        if '-h' in args or '--help' in args:
            usage = getattr(command.module, "usage", None)
            if not usage:
                print >> sys.stderr, "error: no help for " + name
                sys.exit(1)

            usage() # doesn't return

        return command

    def run(self, name, args):
        command = self._pre_run(name, args)

        if self.use_profiler and self.use_debugger:
            raise self.Error("can't use both profiler and debugger")

        is_running_suid = os.getuid() != os.geteuid()
        if is_running_suid and self.use_debugger:
            raise self.Error("won't allow debugger while running suid")

        if self.use_debugger:
            self._debug(command)
        elif self.use_profiler:
            self._profile(command)
        else:
            command.module.main()

    def _debug(self, command):
        import pdb
        pdb.runcall(command.module.main)

    def _profile(self, command):
        import profile
        import pstats
        import tempfile

        statsfile = tempfile.mkstemp(".prof")[1]
        profile.runctx('command.module.main()', globals(), locals(), statsfile)
        pstats.Stats(statsfile).strip_dirs().sort_stats('cumulative').print_stats()

        os.remove(statsfile)

    def __len__(self):
        return len(self.commands)

class CliWrapper:
    DESCRIPTION = ""

    COPYRIGHT = "TurnKey GNU/Linux - http://www.turnkeylinux.org"

    # location of our python modules (relative to INSTALL_PATH)
    PATH_LIB = "pylib"

    # location of our executables (relative to INSTALL_PATH)
    PATH_LIBEXEC = "libexec"

    # this variable allows you to optionally specify the order commands
    # are printed in Commands.usage().
    #
    # "" prints an newline in the usage order

    COMMANDS_USAGE_ORDER = []

    @classmethod
    def get_version(cls):
        """Gets version of program -> version

        Looks for version in the following places (by order):
        1) <INSTALL_PATH>/version.txt (if it exists)
        2) debian/changelog (if it exists - parsed with dpkg-parsechangelog)
        3) `autoversion HEAD`
        """

        version_file = join(cls.INSTALL_PATH, "version.txt")

        if lexists(version_file):
            return file(version_file).readline().strip()

        orig_cwd = os.getcwd()

        if cls.INSTALL_PATH:
            os.chdir(cls.INSTALL_PATH)

        try:
            if not exists("debian/changelog"):
                output = getoutput("autoversion HEAD")
                version = output
            else:
                output = getoutput("dpkg-parsechangelog")
                version = [ line.split(" ")[1]
                            for line in output.split("\n")
                            if line.startswith("Version:") ][0]
        except ExecError:
            os.chdir(orig_cwd)
            return "?"

        os.chdir(orig_cwd)
        return version

    @classmethod
    def get_copyright(cls):
        return "version %s (c) %s" % (cls.get_version(), cls.COPYRIGHT)

    @classmethod
    def main(cls):
        if "--version" in sys.argv:
            print cls.get_version()
            sys.exit(0)

        if cls.PATH_LIBEXEC:
            os.environ['PATH'] = join(cls.INSTALL_PATH, cls.PATH_LIBEXEC) + ":" + \
                                 os.environ['PATH']

        pylib_path = join(cls.INSTALL_PATH, cls.PATH_LIB)
        sys.path.insert(0, pylib_path)

        commands = _Commands(pylib_path, cls)
        if len(commands) > 1:
            av0 = get_av0()

            # project-name? (symbolic link)
            try:
                name = av0[av0.index('-') + 1:]
                args = sys.argv[1:]
            except ValueError:
                try:
                    opts, args = getopt.getopt(sys.argv[1:], 'pdh')
                except getopt.GetoptError, e:
                    commands.usage(e)

                for opt, val in opts:
                    if opt == '-h':
                        commands.usage()
                    if opt == '-p':
                        commands.use_profiler = True
                    elif opt == '-d':
                        commands.use_debugger = True

                if not args:
                    commands.usage()

                name = args[0]
                args = args[1:]

            if not commands.exists(name):
                commands.usage("no such name '%s'" % name)

        else:
            name = commands.get_names()[0]
            args = sys.argv[1:]

        try:
            commands.run(name, args)
        except commands.Error, e:
            fatal(e)



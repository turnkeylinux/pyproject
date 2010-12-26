#!/usr/bin/python
# Copyright (c) 2010 TurnKey Linux - all rights reserved
"""Python project skeleton
"""
from os.path import *
import pyproject

class CliWrapper(pyproject.CliWrapper):
    DESCRIPTION = __doc__
    
    INSTALL_PATH = dirname(__file__)

    # this variable allows you to optionally specify the order commands
    # are printed in Commands.usage().
    #
    # "" prints an newline in the usage order
    COMMANDS_USAGE_ORDER = []

if __name__ == '__main__':
    CliWrapper.main()

#!/usr/bin/python
"""Prints the cli arguments the user provided.

This is not a very interesting command. You should see
this description when you try asking for help on the command.
"""
import sys
import help

@help.usage(__doc__)
def usage():
    print >> sys.stderr, "Syntax: %s [args]" % sys.argv[0]
    
def main():
    print "printing args: " + `sys.argv`
    
if __name__=="__main__":
    main()


<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet ekr_test?>
<leo_file>
<leo_header file_format="2" tnodes="0" max_tnode_index="50" clone_windows="0"/>
<globals body_outline_ratio="0.527331189711">
	<global_window_position top="0" left="570" height="933" width="700"/>
	<global_log_window_position top="0" left="0" height="0" width="0"/>
</globals>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="zaril.20101001195902" a="E"><vh>Project</vh>
<v t="zaril.20110206013108" a="E"><vh>documentation</vh>
<v t="zaril.20110206013108.2"><vh>features</vh></v>
<v t="zaril.20110206013108.3"><vh>usage</vh></v>
<v t="zaril.20110206013108.4" a="TV"><vh>Makefile extension mechanism</vh></v>
<v t="zaril.20110206013108.5"><vh>Makefile API</vh></v>
</v>
<v t="zaril.20101001200718" a="E"><vh>development log</vh>
<v t="zaril.20110127054552"><vh>modify pyproject to support suid Python scripts</vh></v>
<v t="zaril.20110104133327" a="E"><vh>restructure pyproject to eliminate Makefile duplication</vh>
<v t="zaril.20110105105904" a="M"><vh>restructured pyproject initialization</vh></v>
<v t="zaril.20110105102854" a="M"><vh>pyproject-common installation</vh></v>
<v t="zaril.20110105105904.1" a="M"><vh>build pyproject-common</vh></v>
<v t="zaril.20110105110028" a="M"><vh>suid support</vh></v>
<v t="zaril.20110105122542" a="M"><vh>globalize support scripts</vh></v>
<v t="zaril.20110104133327.1" a="EM"><vh>import pyproject.py from turnkey-pylib</vh>
<v t="zaril.20110105154504" a="M"><vh>bug: the python wrapper doesn't work anymore</vh></v>
</v>
<v t="zaril.20110105131729" a="EM"><vh>centralized debian/rules</vh>
<v t="zaril.20110105150653"><vh>options</vh></v>
</v>
<v t="zaril.20110105174253" a="M"><vh>add debug target to pyproject.mk</vh></v>
<v t="zaril.20110105175348" a="M"><vh>refactor pyproject.mk</vh></v>
<v t="zaril.20110105223455" a="M"><vh>add inheritable hooking mechanism</vh></v>
<v t="zaril.20110105150435" a="EM"><vh>port all pyprojects</vh></v>
<v t="zaril.20110106083604" a="EM"><vh>make share/debian-rules.mk extendable</vh>
<v t="zaril.20110106091356" a="M"><vh>bug: builds twice</vh></v>
</v>
</v>
</v>
<v t="zaril.20101001200109.1" a="E"><vh>bugs/wishlist</vh>
<v t="zaril.20110131202606"><vh>add support for accessing internal libraries</vh></v>
<v t="zaril.20110104133430.1"><vh>add template support for external libraries</vh></v>
<v t="zaril.20110105101835"><vh>set maintainer automatically at init?</vh></v>
<v t="zaril.20110104133327.2"><vh>release v1.0 of pyproject</vh></v>
<v t="zaril.20110105165502"><vh>bug: nodoc doesn't work anymre?</vh></v>
</v>
</v>
</vnodes>
<tnodes>
<t tx="zaril.20101001195902">@nocolor
</t>
<t tx="zaril.20101001200109.1"></t>
<t tx="zaril.20101001200718"></t>
<t tx="zaril.20110104133327">* SUMMARY:
basic design
    pyproject has two components
        pyproject-common: common infrastructure stuff
            (e.g., common Makefiles, external libraries, etc.)

        by default in /usr/share/pyproject
            PYPROJECT_MAKEFILE_INCLUDE_PATH ?= ...
                can be overrided to support testing of local installation

    the pyproject template

ramification: two packages with the same version could have different contents

we have 36 projects with 36 different Makefiles

make duplication in
    pyproject/debian/rules
    pyproject/Makefile
        suid files
        explicit progname
        extra installation work (e.g., copy templates/*)
            can be implemented with hooks

* QUESTIONS
Q: how will pyproject install itself?
    it probably shouldn't install the pyproject example at all
        only the contrib stuff

    maybe it should redirect to a specialized Makefile 
        (instead of it all being in one place)

* IDEAS:
separate pyproject package
    disabled when we init another project

will also distribute pyproject's cli wrapper class?
    doesn't really belong in turnkey-pylib anyway

pyproject-common
    /usr/share/pyproject/Makefile
    /usr/share/pyproject/debian-rules.mk

    setup.py install pyproject module

extend pyproject's to be able to install external modules
    so useraufs could install a module for controlling useraufs
        some more things we could remove from turnkey-pylib (or not add to it)

extend pyproject to be able to install *.mk fragments?
    contrib would work...
        but it isn't right for critical Makefiles is it?
        why not? descendent pyprojects don't HAVE to use it
            they can supply their own, so it is contributory

    locations
        /usr/share/pyproject/contrib/build.mk        
        /usr/lib/pyproject/mk/

use pyproject-common Makefile to install pyproject
    disable installation of pyproject software itself


* ROADMAP
pyproject-specific Makefile until initialization
    installs the Makefile into /usr/local/share/pyproject/contrib
    (eventually) pyproject.py as an external library

when pyproject is built it builds pyproject-common

initialization
    replaces Makefile with pointer to pyproject Makefile
    removes pyproject-common crap from debian/control
        replaces debian/control with a decent template        

no scripts - just Makefile stuff?

* SCRATCH

Makefile
    help is default
    install
    init

* TEST:
    </t>
<t tx="zaril.20110104133327.1"></t>
<t tx="zaril.20110104133327.2"></t>
<t tx="zaril.20110104133430.1">QUESTION:
    how do I support using programs at the library level?
        I.e., instead of using Sumo through its cli interface, use it directly from modules
            special pyproject import?

rational
* code duplication: a program should have only one interface, not multiple re-implementations
* encapsulation: when my program's cli interface changes, the program author can change the
python interface

example: useraufs module for other programs to interface with useraufs (without rolling their own)

</t>
<t tx="zaril.20110105101835"></t>
<t tx="zaril.20110105102854">* SUMMARY

share/pyproject.mk

PYPROJECT_MAKEFILE_INCLUDE_PATH
    if defined use that, otherwise use hardwired default

* TEST:

# 2
cd pyproject
make install







</t>
<t tx="zaril.20110105105904">cp -a pyproject test
make init name=test

tips: perform steps manually</t>
<t tx="zaril.20110105105904.1">TEST:
    pool-register pyproject into a pool
    get pyproject-common


</t>
<t tx="zaril.20110105110028">* SUMMARY
    INSTALL_SUID

    don't let INSTALL_SUID or INSTALL_MODE be set in the environment

        solutions
            set it explicitly 
                INSTALL_SUID =
    
            raise an error if it comes from the environment
                $(if $(findstring environment, $(origin INSTALL_SUID)), $(error INSTALL_SUID set unsafely))
    
* TEST:
    port useraufs project

* SCRATCH

add pyproject-common to build-depends</t>
<t tx="zaril.20110105122542">with PYPROJECT_MAKEFILE_INCLUDE_PATH?

Q: where to install the support scripts?
A:
    /usr/share
        for architecture independent data and executable scripts
</t>
<t tx="zaril.20110105131729">debian-rules.mk

configurable globally 
    by changing pyproject's 


TEST: init pyproject as test and try to get it

GOTCHA: pbuilder can't get pyproject-common
    workaround: install pyproject-common manually into the feisty buildroot


* IDEAS:
deckdebuild shouldn't use pbuilder to resolve build dependencies?
    or rather it should try to resolve the dependencies with a pool first? 

give the pool an apt-like interface so we can get packages from it?

extend apt so it know



</t>
<t tx="zaril.20110105150435">ectoplasm is a special case
    review Alon's patch to see how he handled it

write email to alon explaining how to port his packages

HOWTO:
    cd projects
    echo 'porting to pyproject 1.0' &gt; msg
    
    # foreach project
    
    cd yourproject
    
    git-rm -r scripts/;
    
    # if your old Makefile does something non-standard you'll need to use
    # the extension mechanism (more about that later)
    cp /turnkey/projects/pyproject/template/Makefile ./
    cp /turnkey/projects/pyproject/template/debian/rules debian/rules
    
    # add pyproject-common to the build-depends and depends
    # remove dependencies on debhelper, turnkey-pylib and python 
    # (pyproject-common takes care of that)
    editor debian/control
    
    git-commit -a -v -F ../msg -e
        </t>
<t tx="zaril.20110105150653">no documentation

INSTALL_NODOC

</t>
<t tx="zaril.20110105154504">problem: its not seeing the pyproject module because we deleted the pyc and py versions

IDEA:
    compile execproxy and point to it instead of wrapper.py?
        nah, the execproxy only works with installed wrappers

SOLUTION: python -O wrapper.py --version


</t>
<t tx="zaril.20110105165502">py_compile behaves differently on Python 2.5

DISCOVERY: what worked 
E: compile on gentoo and compile on feisty

/usr/lib/python2.4/

python -OO /usr/lib/python2.4/py_compile.py cmd_example.py</t>
<t tx="zaril.20110105174253"></t>
<t tx="zaril.20110105175348"></t>
<t tx="zaril.20110105223455">EXTENDABLE_TARGETS = help build install uninstall clean

undefined hooks
    target/pre
    target/post
    target/deps/extra
    
override after
    target/deps
    target/body
    </t>
<t tx="zaril.20110106083604">extendable_targets = build build-arch build-indep binary

* RESOURCE: Debian Policy Manual 4.9 (Main building script)

build
    not invoked as root

    build-arch build-indep (optional)
        build routines for creating architecture specific and architecture non-specific packages
    
binary binary-arch binary-indep
    invoked as root (or fakeroot)

clean
    undo effects of build

* DESIGN

EXTENDABLE_TARGETS = build clean binary-indep binary-arch</t>
<t tx="zaril.20110106091356">build was duplicated 3 times
</t>
<t tx="zaril.20110127054552">install execproxy suid
    
add "make suidinit target?"
    no, if you want to make a suid program, you better know what to do
        add commented Makefile target

execproxy, sanitizes environment if run suid:
    look at setuid-wrapper in Python distribution

    set safe PATH
        /sbin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

    unset PATH
        force program to set PATH explicitly?

    sanitize PATH of any directories not owned by root?
        we would also have to check with parents, etc.
            
    IFS
    ENV
    LD_*
    PYTHON*        
    CDPATH
    
    set umask
        to 077 or 022 if you want files to be readable

Q: what's euid for a suid program?
A: the owner of the suid program

E: test that clean_environ really does its job
R: it does
    DISCOVERY: the Linux kernel filters LD_PRELOAD for suid files
    clean_environ never gets a chance to filter LD_PRELOAD
        but it does filter LD_PRELOAD_FOO, or whatever
            because it filters any environment variable beginning with LD_

IDEA: ipython as an interactive exploration/testing environment for suid test

    GOTCHA: system("ipython") won't work -&gt; os.geteuid == os.getuid()
        DISCOVERY: bash shell cancels suid effect (sets real uid to uid)
            this means you can't use system to execute a command as suid root
        SOLUTION: execl("/usr/bin/ipython", "ipython",  NULL);    

HYPO: maybe the shell is screwing with my euid credentials?

Q: how do I drop privileges in a suid python program?
A: 
    either
        os.setuid(os.getuid())
            loose privileges permanently

            equivalent to: os.setreuid(os.getuid(), os.getuid())

        os.seteuid(os.getuid())
            drop privileges temporarily
            can still regain privileges by executing os.seteuid(0)
    
    a fuller version - rom connagent/pylib/popen4.py
    
        def _drop_privileges(self, user):
            pwent = pwd.getpwnam(user)
            uid, gid, home = pwent[2], pwent[3], pwent[5]
            del os.environ["XAUTHORITY"]
            os.environ["USER"] = user
            os.environ["HOME"] = home
    
            usergroups = []
            groups = grp.getgrall()
            for group in groups:
                if user in group[3]:
                    usergroups.append(group[2])
            
            os.setgroups(usergroups)
            os.setgid(gid)
            os.setuid(uid)</t>
<t tx="zaril.20110131202606">usage scenario
    create an instance of a pool, without invoking Python interpreter
</t>
<t tx="zaril.20110206013108">Copyright (c) 2010-2011 TurnKey Linux - all rights reserved

Python turnkey toolkit template, with two example commands
1) example # dummy example command that parses options
2) prog # prints 'prog' not implemented</t>
<t tx="zaril.20110206013108.2">* leverage common infrastructure (pyproject-common):
pyproject.py Python module for wrapper cli
shared base Makefiles
shred utility scripts

* integrated help support
(e.g., command docstrings are automatically interpreted by wrapper)

* sourceless installation target
all python modules byte compiled with -OO (strips program of docstrings)

the sourceless python program is executed through a binary execution proxy
        allowing MAC rules to be applied to the toolkit
        prevents python environment manipulation tricks
                tricks that could be used to exploit privileged python apps
        cleans the environment prior to execution in suid mode
                clears LD_* variables
                sets PATH, CDPATH, IFS to good values

* debian packaging support

* flexible toolkit execution syntax
# lists available commands
project

# runs pylib/cmd_command.py:main()
project command arg1 arg2 ...
project-command arg1 arg2 ...

# if only one command available, this will run it
project arg1 arg2

* wrapper environment setup
automatically sets up pylib into your python path
automatically sets up libexec into your PATH

* versioning support
Looks for version in the following places (by order):
1) &lt;INSTALL_PATH&gt;/version.txt (if it exists)
2) debian/changelog (if it exists - parsed with dpkg-parsechangelog)
3) `autoversion HEAD`

To print out program version:
        project --version

* integrated profiler support
project -p subcommand args...
project-subcommand --profile args...

* integrated debugging support
project -d subcommand args...
project-subcommand --debug args..</t>
<t tx="zaril.20110206013108.3">* initialization:
cp -a pyproject newproject
cd newproject &amp;&amp; make init

* update packaging files
        eg. debian/control with descriptions and dependencies

* remove example dummy commands?
        pylib/cmd_printargs.py
        pylib/cmd_prog.py

* add programs to the toolkit as pylib/cmd_&lt;subcmd&gt;.py

* Makefile help usage
        make || make help

* update links (when you have added or removed commands)
        make updatelinks

Remember, you can run toolkit commands like this:
        pylib/cmd_&lt;subcmd&gt;.py arg1 arg2 ...
        &lt;progname&gt;-&lt;subcmd&gt; arg1 arg2 ...
        &lt;progname&gt; &lt;subcmd&gt; arg1 arg2 ...

* documentation / integrated help
Usage:
&lt;progname&gt; # prints high level overview of programs + help
&lt;progname&gt;-&lt;command&gt; -h # extended help

Notes:
- The first line of a cmd_* module docstring is the short usage desc.
- commands that have a usage() function, support the -h flag for extended help.
- The help module defines a usage decorator for convenience.
Example usage (see cmd_printargs for an example):

import help
@help.usage(__doc__)
def usage():
        print "Syntax: foo"

Advanced:
Normally, the order of the commands printed by &lt;progname&gt; is
determined by their sort order. If you want to manually tweak with
the order, then list the desired order in
wrapper.CliWrapper.COMMANDS_USAGE_ORDER.

Empty string values COMMANDS_USAGE_ORDER symbolize empty lines/seperators.

* install
make install prefix=...  # prefix defaults to /usr/local

* uninstall
make uninstall          # prefix defaults to /usr/local

* tag the latest commit as a versioned release:

# this will ask you for a tag message (which may include release notes)
# and create a tag signed by your GPG key
git-tag -s v1.0.1

(if available, use of git-tag-release is recommended)</t>
<t tx="zaril.20110206013108.4">pyproject-common's Makefiles (debian-rules.mk and debian-rules.mk)
are designed to be configurable and extendable with `define' based hooks
which are set BEFORE including the shared Makefile because target
prerequisites are evaluated at include time:

        &lt;target&gt;/pre  # rules before default body (default: empty)
        &lt;target&gt;/post # rules after default body (default: empty)

        &lt;target&gt;/deps # override default dependencies for a rule
        &lt;target&gt;/deps/extra # extra dependencies for rule (default: empty)

Special case - if you want to override built in built-in rules for a target,
you'll need to define them AFTER including the shared Makefile
        &lt;target&gt;/body # body of rules (default: defined, but can be overridden)

To override built-in variables you'll need to define them AFTER the include.

Most pyprojects don't need to extend the default Makefiles, but
extending and overriding default behavior is occasionally needed to
satisfy special use cases (e.g., connagent and opus).

For example:

$ cd opus
$ cat Makefile
PATH_INSTALL_TEMPLATES = $(PATH_INSTALL)/templates

define help/post
        @echo
        @echo "templates                        # make templates/generated"
endef

templates:
        cd templates &amp;&amp; ./generate.py

build/deps/extra = templates

define install/post
        install -d $(PATH_INSTALL_TEMPLATES)
        cp -a templates/generated $(PATH_INSTALL_TEMPLATES)
endef

.PHONY: templates

PYPROJECT_SHARE_PATH ?= /usr/share/pyproject
include $(PYPROJECT_SHARE_PATH)/pyproject.mk</t>
<t tx="zaril.20110206013108.5">pyproject.mk:
        INSTALL_SUID   # if not empty string, install program suid
        INSTALL_NODOC  # if not empty string, compile without docstrings

        EXTENDABLE_TARGETS = help build install uninstall clean

debian-rules.mk:
        EXTENDABLE_TARGETS = build clean binary-indep binary-arch</t>
</tnodes>
</leo_file>

<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet ekr_test?>
<leo_file>
<leo_header file_format="2" tnodes="0" max_tnode_index="49" clone_windows="0"/>
<globals body_outline_ratio="0.5">
	<global_window_position top="0" left="453" height="933" width="816"/>
	<global_log_window_position top="0" left="0" height="0" width="0"/>
</globals>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="zaril.20101001195902" a="E"><vh>Project</vh>
<v t="zaril.20101001200718" a="E"><vh>development log</vh>
<v t="zaril.20110104133327" a="E"><vh>restructure pyproject to eliminate Makefile duplication</vh>
<v t="zaril.20110105102854" a="TV"><vh>pyproject-common installation</vh></v>
</v>
</v>
<v t="zaril.20101001200109.1" a="E"><vh>bugs/wishlist</vh>
<v t="zaril.20110104133327.1"><vh>import pyproject.py from turnkey-pylib</vh></v>
<v t="zaril.20110104133430"><vh>update documentation</vh></v>
<v t="zaril.20110104133430.1"><vh>add support for external libraries</vh></v>
<v t="zaril.20110105101835"><vh>set maintainer automatically at init?</vh></v>
<v t="zaril.20110104133327.2"><vh>release v1.0</vh></v>
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

PYPROJECT_MAKEFILE_INCLUDE_PATH
    if defined use that, otherwise use hardwired default

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

# 1
cp -a pyproject test
make init name=test

tips: perform steps manually


# 3 build pyproject-common


    </t>
<t tx="zaril.20110104133327.1"></t>
<t tx="zaril.20110104133327.2"></t>
<t tx="zaril.20110104133430"></t>
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

* TEST:

# 2
cd pyproject
make install







</t>
</tnodes>
</leo_file>

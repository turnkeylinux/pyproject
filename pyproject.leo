<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet ekr_test?>
<leo_file>
<leo_header file_format="2" tnodes="0" max_tnode_index="49" clone_windows="0"/>
<globals body_outline_ratio="0.363344051447">
	<global_window_position top="0" left="570" height="933" width="700"/>
	<global_log_window_position top="0" left="0" height="0" width="0"/>
</globals>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="zaril.20101001195902" a="E"><vh>Project</vh>
<v t="zaril.20101001200718" a="E"><vh>development log</vh>
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
<v t="zaril.20110105175348" a="MTV"><vh>refactor pyproject.mk</vh></v>
<v t="zaril.20110105223455" a="M"><vh>add inheritable hooking mechanism</vh></v>
<v t="zaril.20110105150435" a="E"><vh>port all pyprojects</vh></v>
</v>
</v>
<v t="zaril.20101001200109.1" a="E"><vh>bugs/wishlist</vh>
<v t="zaril.20110104133430"><vh>update documentation</vh></v>
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
<t tx="zaril.20110105150435">rm -rf scripts
replace Makefile
add pyproject-common to build depends and depends


ectoplasm is a special case
    review Alon's patch to see how he handled it

write email to alon explaining how to port his packages

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
</tnodes>
</leo_file>

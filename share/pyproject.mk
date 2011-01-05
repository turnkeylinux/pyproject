_self = $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
PYPROJECT_SHARE_PATH ?= $(shell dirname $(_self))

# standard Python project Makefile
progname=$(shell awk '/^Source/ {print $$2}' debian/control)
name=

prefix=/usr/local
PATH_BIN=$(prefix)/bin

# WARNING: PATH_INSTALL is rm-rf'ed in uninstall
PATH_INSTALL=$(prefix)/lib/$(progname)
PATH_INSTALL_LIB=$(PATH_INSTALL)/pylib
PATH_INSTALL_LIBEXEC=$(PATH_INSTALL)/libexec
PATH_INSTALL_SHARE=$(prefix)/share/$(progname)
PATH_INSTALL_CONTRIB=$(PATH_INSTALL_SHARE)/contrib

TRUEPATH_INSTALL=$(shell echo $(PATH_INSTALL) | sed -e 's/debian\/$(progname)//g')

PYTHON_LIB=$(shell echo /usr/lib/python* | sed 's/.* //')

PYCC_FLAGS=$(if $(INSTALL_NODOC),-OO,-O)
PYCC=python $(PYCC_FLAGS) $(PYTHON_LIB)/py_compile.py

PATH_DIST := $(progname)-$(shell date +%F)

# set explicitly to prevent INSTALL_SUID being set in the environment
INSTALL_SUID = 
INSTALL_FILE_MOD = $(if $(INSTALL_SUID), 4755, 755)

all: help

help:
	@echo "=== USAGE ==="
	@echo 
	@echo "make install prefix=<dirpath>"
	@echo "         (default prefix $(prefix))"
	@echo "make uninstall prefix=<dirpath>"
	@echo
	@echo "make clean"
	@echo "make dist                       # create distribution tarball"
	@echo "make gitdist                    # create git distribution tarball"
	@echo
	@echo "make rename name=<project-name> # initialize project"
	@echo "make updatelinks                # update toolkit command links"
	@echo 

debug:
	$(foreach v, $V, $(warning $v = $($v)))
	@true

rename:
	$(if $(name),,($(error 'name' not set)))
	$(PYPROJECT_SHARE_PATH)/rename.sh $(progname) $(name)

updatelinks:
	@echo -n updating links... " "
	@$(PYPROJECT_SHARE_PATH)/updatelinks.sh
	@echo done.
	@echo

execproxy: execproxy.c
	gcc execproxy.c -DMODULE_PATH=\"$(TRUEPATH_INSTALL)/wrapper.pyo\" -o _$(progname)
	strip _$(progname)

build: execproxy
	$(PYCC) pylib/*.py *.py

uninstall:
	rm -rf $(PATH_INSTALL)
	rm -rf $(PATH_INSTALL_SHARE)
	rm -f $(PATH_BIN)/$(progname)

	# delete links from PATH_BIN
	for f in $(progname)-*; do rm -f $(PATH_BIN)/$$f; done

install: build
	@echo
	@echo \*\* CONFIG: prefix = $(prefix) \*\*
	@echo 

	install -d $(PATH_BIN) $(PATH_INSTALL) $(PATH_INSTALL_LIB) $(PATH_INSTALL_LIBEXEC)

	# if contrib exists
	contrib=$$(echo contrib/*); \
	if [ "$$contrib" != "contrib/*" ]; then \
		mkdir -p $(PATH_INSTALL_CONTRIB); \
		cp -a contrib/* $(PATH_INSTALL_CONTRIB); \
	fi

	install -m 644 pylib/*.pyo $(PATH_INSTALL_LIB)
	-install -m 755 libexec/* $(PATH_INSTALL_LIBEXEC)

	install -m 644 wrapper.pyo $(PATH_INSTALL)
	python -O wrapper.py --version > $(PATH_INSTALL)/version.txt

	for f in $(progname)*; do \
		if [ -x $$f ]; then \
			cp -P $$f $(PATH_BIN); \
		fi; \
	done
	rm -f $(PATH_BIN)/$(progname)
	install -m $(INSTALL_FILE_MOD) _$(progname) $(PATH_BIN)/$(progname)

clean:
	rm -f pylib/*.pyc pylib/*.pyo *.pyc *.pyo _$(progname)

dist: clean
	-mkdir -p $(PATH_DIST)

	-cp -a .git .gitignore $(PATH_DIST)
	-cp -a *.sh *.c *.py Makefile pylib/ libexec* $(PATH_DIST)

	tar jcvf $(PATH_DIST).tar.bz2 $(PATH_DIST)
	rm -rf $(PATH_DIST)


gitdist: clean
	-mkdir -p $(PATH_DIST)-git
	-cp -a .git $(PATH_DIST)-git
	cd $(PATH_DIST)-git && git-repack -a -d

	tar jcvf $(PATH_DIST)-git.tar.bz2 $(PATH_DIST)-git
	rm -rf $(PATH_DIST)-git

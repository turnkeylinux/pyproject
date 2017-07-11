# Copyright (c) TurnKey GNU/Linux - http://www.turnkeylinux.org
#
# This file is part of pyproject
#
# pyproject is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.

_self = $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
PYPROJECT_SHARE_PATH ?= $(shell dirname $(_self))

# standard Python project Makefile
progname = $(shell awk '/^Source/ {print $$2}' debian/control)
name=

truepath = $(shell echo $1 | sed -e 's/^debian\/$(progname)//')

prefix = /usr/local
PATH_BIN = $(prefix)/bin

# WARNING: PATH_INSTALL is rm-rf'ed in uninstall
PATH_INSTALL = $(prefix)/lib/$(progname)

PATH_INSTALL_LIB = $(PATH_INSTALL)/pylib
PATH_INSTALL_LIBEXEC = $(PATH_INSTALL)/libexec
PATH_INSTALL_SHARE = $(prefix)/share/$(progname)
PATH_INSTALL_CONTRIB = $(PATH_INSTALL_SHARE)/contrib

PATH_DIST := $(progname)-$(shell date +%F)

# set explicitly to prevent INSTALL_SUID being set in the environment
INSTALL_SUID = 
INSTALL_FILE_MOD = $(if $(INSTALL_SUID), 4755, 755)

all: help

debug:
	$(foreach v, $V, $(warning $v = $($v)))
	@true

dist: clean
	-mkdir -p $(PATH_DIST)

	-cp -a .git .gitignore $(PATH_DIST)
	-cp -a *.sh *.c *.py Makefile pylib/ libexec* $(PATH_DIST)

	tar jcvf $(PATH_DIST).tar.bz2 $(PATH_DIST)
	rm -rf $(PATH_DIST)


gitdist: clean
	-mkdir -p $(PATH_DIST)-git
	-cp -a .git $(PATH_DIST)-git
	cd $(PATH_DIST)-git && git repack -a -d

	tar jcvf $(PATH_DIST)-git.tar.bz2 $(PATH_DIST)-git
	rm -rf $(PATH_DIST)-git

rename:
	$(if $(name),,($(error 'name' not set)))
	$(PYPROJECT_SHARE_PATH)/rename.sh $(progname) $(name)

updatelinks:
	@echo -n updating links... " "
	@$(PYPROJECT_SHARE_PATH)/updatelinks.sh $(progname)
	@echo done.
	@echo

execproxy: execproxy.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) execproxy.c -DMODULE_PATH=\"$(call truepath,$(PATH_INSTALL))/wrapper.py\" -o _$(progname)
	strip _$(progname)

### Extendable targets

# target: help
define help/body
	@echo '=== Configuration variables:'
	@echo 'INSTALL_SUID   # if not empty string, install program suid'
	@echo 'INSTALL_NODOC  # if not empty string, compile without docstrings'
	@echo

	@echo '=== Targets:'
	@echo 'install   [ prefix=path/to/usr ] # default: prefix=$(value prefix)'
	@echo 'uninstall [ prefix=path/to/usr ]'
	@echo
	@echo 'updatelinks [ progname=name ]    # update toolkit wrapper links'
	@echo
	@echo 'rename name=<newname>'
	@echo 'clean'
	@echo
	@echo 'dist                             # create distribution tarball'
	@echo 'gitdist                          # create git distribution tarball'
endef

# target: build
build/deps ?= execproxy

# target: install
install/deps ?= build
define install/body
	@echo
	@echo \*\* CONFIG: prefix = $(prefix) \*\*
	@echo 

	install -d $(PATH_BIN) $(PATH_INSTALL) $(PATH_INSTALL_LIB) $(PATH_INSTALL_LIBEXEC)

	# if share exists
	if [ "$(wildcard share/*)" ]; then \
		mkdir -p $(PATH_INSTALL_SHARE); \
		cp -a share/* $(PATH_INSTALL_SHARE); \
	fi

	# if contrib exists
	if [ "$(wildcard contrib/*)" ]; then \
		mkdir -p $(PATH_INSTALL_CONTRIB); \
		cp -a contrib/* $(PATH_INSTALL_CONTRIB); \
	fi

	install -m 644 pylib/*.py $(PATH_INSTALL_LIB)
	-install -m 755 libexec/* $(PATH_INSTALL_LIBEXEC)

	install -m 644 wrapper.py $(PATH_INSTALL)
	python -O wrapper.py --version > $(PATH_INSTALL)/version.txt

	for f in $(progname)*; do \
		if [ -x $$f ]; then \
			cp -P $$f $(PATH_BIN); \
		fi; \
	done
	rm -f $(PATH_BIN)/$(progname)
	install -m $(INSTALL_FILE_MOD) _$(progname) $(PATH_BIN)/$(progname)

	find $(PATH_INSTALL) -type d -empty -delete
endef

# target: uninstall
define uninstall/body
	rm -rf $(PATH_INSTALL)
	rm -rf $(PATH_INSTALL_SHARE)
	rm -f $(PATH_BIN)/$(progname)

	# delete links from PATH_BIN
	for f in $(progname)-*; do rm -f $(PATH_BIN)/$$f; done
endef

# target: clean
define clean/body
	rm -f pylib/*.pyc pylib/*.pyo *.pyc *.pyo _$(progname)
endef

# construct target rules
define extendable_target
$1: $$($1/deps) $$($1/deps/extra)
	$$($1/pre)
	$$($1/body)
	$$($1/post)
endef

EXTENDABLE_TARGETS = help build install uninstall clean
$(foreach target,$(EXTENDABLE_TARGETS),$(eval $(call extendable_target,$(target))))

.PHONY: gitdist dist updatelinks rename debug $(EXTENDABLE_TARGETS)

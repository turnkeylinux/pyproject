# standard Python project Makefile

prefix=/usr/local

PROGNAME=project
PATH_BIN=$(prefix)/bin

# WARNING: PATH_INSTALL is rm-rf'ed in uninstall
PATH_INSTALL=$(prefix)/lib/$(PROGNAME)
PATH_INSTALL_LIB=$(PATH_INSTALL)/pylib
PATH_INSTALL_LIBEXEC=$(PATH_INSTALL)/libexec

PYCC=python -OO /usr/lib/python/py_compile.py

PATH_DIST := $(PROGNAME)-$(shell date +%F)

all:
	@echo To install \(by default prefix=$(prefix)\): 
	@echo     make install prefix=...

pycompile:
	$(PYCC) pylib/*.py *.py

execproxy: execproxy.c
	gcc execproxy.c -DMODULE_PATH=\"$(PATH_INSTALL)/wrapper.pyo\" -o _$(PROGNAME)
	strip _$(PROGNAME)

uninstall:
	rm -rf $(PATH_INSTALL)
	rm -f $(PATH_BIN)/$(PROGNAME)

install: pycompile execproxy
	@echo
	@echo \*\* CONFIG: prefix = $(prefix) \*\*
	@echo 

	install -d $(PATH_BIN) $(PATH_INSTALL) $(PATH_INSTALL_LIB) $(PATH_INSTALL_LIBEXEC)

	install -m 644 pylib/*.pyo $(PATH_INSTALL_LIB)
	-install -m 755 libexec/* $(PATH_INSTALL_LIBEXEC)

	install -m 644 version.pyo wrapper.pyo $(PATH_INSTALL)
	install -m 755 _$(PROGNAME) $(PATH_BIN)/$(PROGNAME)

clean:
	rm -f pylib/*.pyc pylib/*.pyo *.pyc *.pyo _$(PROGNAME)
	rm -rf build/

dist: clean
	-mkdir -p $(PATH_DIST)

	-cp -a .git .gitignore $(PATH_DIST)
	-cp -a *.sh *.c *.py Makefile pylib/ libexec* $(PATH_DIST)

	tar jcvf $(PATH_DIST).tar.bz2 $(PATH_DIST)
	rm -rf $(PATH_DIST)

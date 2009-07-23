# standard Python project Makefile

PROGNAME=prog
INSTALL_PREFIX:=$(shell pwd)/build
PATH_BIN=$(INSTALL_PREFIX)/bin

# WARNING: PATH_INSTALL is rm-rf'ed in uninstall
PATH_INSTALL=$(INSTALL_PREFIX)/lib/$(PROGNAME)
PATH_INSTALL_LIB=$(PATH_INSTALL)/pylib
PATH_INSTALL_LIBEXEC=$(PATH_INSTALL)/libexec

PYCC=python -OO /usr/lib/python/py_compile.py

PATH_DIST := $(PROGNAME)-$(shell date +%F)

all: install

version:
	@echo `cat version.py|sed 's/.*=//'`|sed 's/ /./'|sed 's/^/current version /'

incversion: version
	@echo "Incrementing version minor in version.py"
	@perl -i -pe 's/minor=(\d+)/"minor=" . ($$1 + 1)/ge' version.py

incver: incversion

pycompile:
	$(PYCC) pylib/*.py *.py

execproxy: execproxy.c
	gcc execproxy.c -DMODULE_PATH=\"$(PATH_INSTALL)/wrapper.pyo\" -o $(PROGNAME)
	strip $(PROGNAME)

pyexecproxy:
	./mkexecproxy.py $(PATH_INSTALL)/wrapper.pyo $(PROGNAME)
	chmod 755 $(PROGNAME)

uninstall:
	rm -rf $(PATH_INSTALL)
	rm -f $(PATH_BIN)/$(PROGNAME)

install: pycompile execproxy
	@echo
	@echo \*\* CONFIG: INSTALL_PREFIX = $(INSTALL_PREFIX) \*\*
	@echo 

	install -d $(PATH_BIN) $(PATH_INSTALL) $(PATH_INSTALL_LIB) $(PATH_INSTALL_LIBEXEC)

	install -m 644 pylib/*.pyo $(PATH_INSTALL_LIB)
	-install -m 755 libexec/* $(PATH_INSTALL_LIBEXEC)

	install -m 644 version.pyo wrapper.pyo $(PATH_INSTALL)
	install -m 755 $(PROGNAME) $(PATH_BIN)

clean:
	rm -f pylib/*.pyc pylib/*.pyo *.pyc *.pyo $(PROGNAME)
	rm -rf build/

dist: clean
	-mkdir -p $(PATH_DIST)

	-cp -a .git .gitignore $(PATH_DIST)
	-cp -a *.sh *.c *.py Makefile pylib/ libexec* $(PATH_DIST)

	tar jcvf $(PATH_DIST).tar.bz2 $(PATH_DIST)
	rm -rf $(PATH_DIST)

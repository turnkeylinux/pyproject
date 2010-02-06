# standard Python project Makefile
progname=pyproject

prefix=/usr/local
PATH_BIN=$(prefix)/bin

# WARNING: PATH_INSTALL is rm-rf'ed in uninstall
PATH_INSTALL=$(prefix)/lib/$(progname)
PATH_INSTALL_LIB=$(PATH_INSTALL)/pylib
PATH_INSTALL_LIBEXEC=$(PATH_INSTALL)/libexec

PYCC=python -OO /usr/lib/python/py_compile.py

PATH_DIST := $(progname)-$(shell date +%F)

all:
	@echo === USAGE ===
	@echo 
	@echo make install prefix=...
	@echo "    " default prefix=$(prefix)
	@echo
	@echo make clean
	@echo make dist
	@echo
	@echo make rename progname=...
	@echo make updatelinks
	@echo

rename:
	scripts/rename.sh $(progname)

updatelinks:
	@echo -n updating links... " "
	@scripts/updatelinks.sh
	@echo done.
	@echo

pycompile:
	$(PYCC) pylib/*.py *.py

execproxy: execproxy.c
	gcc execproxy.c -DMODULE_PATH=\"$(PATH_INSTALL)/wrapper.pyo\" -o _$(progname)
	strip _$(progname)

uninstall:
	rm -rf $(PATH_INSTALL)
	rm -f $(PATH_BIN)/$(progname)

	# delete links from PATH_BIN
	for f in $(progname)-*; do rm -f $(PATH_BIN)/$$f; done

install: pycompile execproxy
	@echo
	@echo \*\* CONFIG: prefix = $(prefix) \*\*
	@echo 

	install -d $(PATH_BIN) $(PATH_INSTALL) $(PATH_INSTALL_LIB) $(PATH_INSTALL_LIBEXEC)

	install -m 644 pylib/*.pyo $(PATH_INSTALL_LIB)
	-install -m 755 libexec/* $(PATH_INSTALL_LIBEXEC)

	install -m 644 version.pyo wrapper.pyo $(PATH_INSTALL)

	install -m 755 _$(progname) $(PATH_BIN)/$(progname)
	cp -P $(progname)-* $(PATH_BIN)	

clean:
	rm -f pylib/*.pyc pylib/*.pyo *.pyc *.pyo _$(progname)
	rm -rf build/

dist: clean
	-mkdir -p $(PATH_DIST)

	-cp -a .git .gitignore $(PATH_DIST)
	-cp -a *.sh *.c *.py Makefile pylib/ libexec* $(PATH_DIST)

	tar jcvf $(PATH_DIST).tar.bz2 $(PATH_DIST)
	rm -rf $(PATH_DIST)

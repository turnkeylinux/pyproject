all: help

name = $(shell basename $(shell pwd))
prefix = /usr/local

PATH_INSTALL_SHARE = $(prefix)/share/pyproject

help:
	@echo '=== Targets'
	@echo
	@echo '# initialize pyproject from template'
	@echo '  init [ name=<name> ] 			# default: name=$$(basename $$(pwd))'
	@echo
	@echo '# install pyproject-common components'
	@echo '  install [ prefix=path/to/usr ]         # default: prefix=$(value prefix)'

init:
ifeq ($(shell basename $(shell pwd)),pyproject)
	$(error won't initialize pyproject in-place)
endif
	rm docs/*

	cp template/.gitignore ./
	cp -a template/* ./
	rm -rf template

	rm -rf tests 
	rm -rf .git

	scripts/rename.sh pyproject $(name)
	git-init 
	git-add .
	git-commit -m "Initialized project '$(name)' from pyproject template"

install:
	mkdir -p $(PATH_INSTALL_SHARE)
	cp -a share/* $(PATH_INSTALL_SHARE)

uninstall:
	rm -rf $(PATH_INSTALL_SHARE)

clean:
	@echo nothing to clean

.PHONY: init

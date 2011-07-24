#! /usr/bin/make -f

### Variables:
# set this to a non-empty string if you want to use the install-nodoc target
# INSTALL_NODOC

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

progname=$(shell awk '/^Source/ {print $$2}' debian/control)
buildroot=debian/$(progname)
prefix=$(buildroot)/usr

EXTENDABLE_TARGETS = build clean binary-indep binary-arch install

export INSTALL_NODOC

binary: binary-indep binary-arch

define build/body
	mkdir -p $(prefix)
endef

install/deps ?= build
define install/body
	dh_clean -k
	dh_testdir
	dh_installdirs
	dh_install
	if [ -d docs ]; then dh_installdocs docs/; fi
	$(MAKE) install prefix=$(prefix)
endef

define clean/body
	$(MAKE) clean
	dh_clean
	rm -f $(EXTENDABLE_TARGETS)
endef

binary-arch/deps ?= build install
define binary-arch/body
	dh_testdir
	dh_testroot
	dh_installdocs
	dh_installdeb -a
	dh_gencontrol -a
	dh_md5sums -a
	dh_builddeb -a
endef

# construct target rules
define extendable_target
$1: $$($1/deps) $$($1/deps/extra)
	$$($1/pre)
	$$($1/body)
	$$($1/post)
	touch $$@
endef
$(foreach target,$(EXTENDABLE_TARGETS),$(eval $(call extendable_target,$(target))))

.PHONY: clean

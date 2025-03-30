#!/bin/env make -f

PACKAGE = $(shell basename $(shell pwd))
VERSION = $(shell bash scripts/set-version)

MAINTAINER = $(shell git config user.name) <$(shell git config user.email)>

INSTALL = btrfs-progs, grub2-common, inotify-tools
BUILD = debhelper (>= 11), git, make (>= 4.1), dpkg-dev

HOMEPAGE = https://github.com/MichaelSchaecher/dpkg-changelog

PACKAGE_DIR = package

ARCH = $(shell dpkg --print-architecture)

export PACKAGE_DIR PACKAGE VERSION MAINTAINER INSTALL BUILD HOMEPAGE ARCH

# Phony targets
.PHONY: all debian clean help

# Default target
all: debian

debian:

	@echo "Building package $(PACKAGE) version $(VERSION)"

	@echo "$(VERSION)" > $(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/version

	@pandoc -s -t man man/$(PACKAGE).8.md -o \
		$(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE).8
	@gzip --best -nvf $(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE).8

	@pandoc -s -t man man/$(PACKAGE)-conf.8.md -o \
		$(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE)-conf.8
	@gzip --best -nvf $(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE)-conf.8

	@dpkg-changelog $(PACKAGE_DIR)/DEBIAN/changelog
	@dpkg-changelog $(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/changelog
	@gzip -d $(PACKAGE_DIR)/DEBIAN/*.gz
	@mv $(PACKAGE_DIR)/DEBIAN/changelog.DEBIAN $(PACKAGE_DIR)/DEBIAN/changelog

	@scripts/sum
	@scripts/set-control
	@scripts/mkdeb

install:

	@dpkg -i $(PACKAGE)_$(VERSION)_$(ARCH).deb

clean:
	@rm -vf $(PACKAGE_DIR)/DEBIAN/control \
		$(PACKAGE_DIR)/DEBIAN/changelog \
		$(PACKAGE_DIR)/DEBIAN/md5sums \
		$(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/*.gz \
		$(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/version \
		$(PACKAGE_DIR)/usr/share/man/man8/*.8.gz

help:
	@echo "Usage: make [target] <variables>"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the debian package and install it"
	@echo "  debian    - Build the debian package"
	@echo "  install   - Install the debian package"
	@echo "  clean     - Clean up build files"
	@echo "  help      - Display this help message"
	@echo ""

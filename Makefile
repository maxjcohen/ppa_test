PACKAGE=aciah
VERSION=$(shell cat VERSION)

prefix = /usr/local
deb_files = ppa/$(PACKAGE)_$(VERSION)-1_amd64.deb ppa/Packages ppa/Packages.gz ppa/Release

install: src/scripts/lecture.sh
	install -D src/scripts/lecture.sh \
		$(DESTDIR)$(prefix)/bin/aciah_lecture

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/aciah_lecture

archive: $(PACKAGE)-$(VERSION).tar.gz
$(PACKAGE)-$(VERSION).tar.gz: src/scripts/lecture.sh VERSION debian/*
	# Create temporary directory
	mkdir -p /tmp/$(PACKAGE)-$(VERSION)
	cp -r ./* /tmp/$(PACKAGE)-$(VERSION)
	mv /tmp/$(PACKAGE)-$(VERSION) .
	# Create tarball
	tar cfz $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	# Remove temporary directory
	rm -r $(PACKAGE)-$(VERSION)

package: $(deb_files)
$(deb_files): $(PACKAGE)-$(VERSION).tar.gz
	# Build docker image
	docker build -t aciah_ppa -f docker/Dockerfile .
	# Package in a container
	mkdir -p ./ppa
	docker run --rm \
	    -v "./$(PACKAGE)-$(VERSION).tar.gz:/orig/$(PACKAGE)-$(VERSION).tar.gz" \
	    -v ./ppa:/ppa \
	    -e PACKAGE="$(PACKAGE)" \
	    -e VERSION="$(VERSION)" \
	    aciah_ppa

clean:
	rm -f $(PACKAGE)-$(VERSION).tar.gz
	rm -f $(deb_files)

.PHONY: install uninstall archive package clean

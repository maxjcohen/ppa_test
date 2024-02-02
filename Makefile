prefix = /usr/local

install: src/scripts/lecture.sh
	install -D src/scripts/lecture.sh \
		$(DESTDIR)$(prefix)/bin/aciah_lecture

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/aciah_lecture

.PHONY: install uninstall

prefix=/usr
PACKAGE=chroots
VERSION=0.2

bindir = ${prefix}/sbin
libdir = ${prefix}/lib
pkglibdir = $(libdir)/chroots
distdir =$(PACKAGE)-$(VERSION)
distdebdir = $(distdir)/debian

DIST_DEB = debian/changelog debian/compat debian/control debian/copyright \
	debian/dirs debian/rules

SOURCES = chroots.in chroots-setup.in chroots-init.in chroots-login.in \
	chroots-stop.in chroots-delete.in chroots-list.in

SCRIPTS = ${SOURCES:.in=}

LIBS = chroots-functions
DIST_SOURCES = $(SOURCES) $(LIBS)
DIST_EXTRA = AUTHORS README TODO COPYING Makefile
DIST_FILES = $(DIST_SOURCES) $(DIST_EXTRA) $(DIST_DEB)

INSTALL = /usr/bin/install -c

do_subst = sed \
	-e 's,[@]bindir[@],$(bindir),g' \
	-e 's,[@]pkglibdir[@],$(pkglibdir),g' \
	-e 's,[@]pkgversion[@],$(VERSION),g' \
	-e 's,[@]pkgname[@],$(PACKAGE),g'

all: $(SCRIPTS) $(LIBS)

%: %.in
	$(do_subst) < $@.in > $@
	chmod +x $@

install-bin: $(SCRIPTS)
	test -z "$(bindir)" || mkdir -p $(bindir)
	@list='$(SCRIPTS)'; for p in $$list; do \
		echo " $(INSTALL) '$$p' '$(bindir)/$$p'"; \
		$(INSTALL) "$$p" "$(bindir)/$$p" || exit 1; \
	done;

install-lib: $(LIBS)
	test -z "$(pkglibdir)" || mkdir -p $(pkglibdir)
	@list='$(LIBS)'; for p in $$list; do \
		echo " $(INSTALL) '$$p' '$(pkglibdir)/$$p'"; \
		$(INSTALL) "$$p" "$(pkglibdir)/$$p" || exit 1; \
	done;

install: all install-bin install-lib

uninstall-bin:
	@list='$(SCRIPTS)'; for p in $$list; do \
		echo " rm -f '$(bindir)/$$p'"; \
		rm -f "$(bindir)/$$p"; \
	done;

uninstall-lib:
	@list='$(LIBS)'; for p in $$list; do \
		echo " rm -f '$(pkglibdir)/$$p'"; \
		rm -f "$(pkglibdir)/$$p"; \
		echo " rm -f '$(pkglibdir)'"; \
		rm -rf "$(pkglibdir)"; \
	done;

uninstall: uninstall-bin uninstall-lib

distdir:
	test -d $(distdir) || mkdir $(distdir)
	test -d $(distdebdir) || mkdir $(distdebdir)
	@list='$(DIST_FILES)'; for file in $$list; do \
		if test -f $$file; then \
			cp -p $$file $(distdir)/$$file || exit 1 \
		else \
			exit 1; \
		fi; \
	done;

dist-gzip: distdir
	tar chof - $(distdir) | gzip -c >$(distdir).tar.gz
	rm -rf $(distdir)

dist-bzip2: distdir
	tar chof - $(distdir) | bzip2 -9 -c >$(distdir).tar.bz2
	rm -rf $(distdir)

dist: dist-gzip

clean:
	@list='$(SCRIPTS)'; for p in $$list; do \
		rm -f $$p; \
	done;

.PHONY: all install install-bin install-lib \
	uninstall uninstall-bin uninstall-lib \
	distdir dist-gzip dist-bzip2 dist clean

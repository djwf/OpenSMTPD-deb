ifeq ($(DESTDIR),)
	destdir=$(HOME)
else
	destdir=$(DESTDIR)
endif

ifeq ($(OPENSMTPD),)
	opensmtpd=$(HOME)/usr/src/OpenSMTPD
else
	opensmtpd=$(OPENSMTPD)
endif

ifeq ($(PACKAGES),)
	packages=$(HOME)/usr/debian-packages
else
	packages=$(PACKAGES)
endif

prefix=$(destdir)/usr/local
exec_prefix=$(prefix)
bindir=$(exec_prefix)/bin
sysconfdir=$(prefix)/etc
sysconfsubdir=$(sysconfdir)/OpenSMTPD-deb

CHMOD=chmod
INSTALL=install
RM=rm
RMDIR=rmdir

all:

install: install-bin install-sysconf

install-bin: create-opensmtpd-deb.sh
	$(INSTALL) -d $(bindir)
	$(INSTALL) $< $(bindir)
	sed -e 's!%%packages%%!$(packages)!' $(bindir)/$< >$(bindir)/$<.new
	sed -e 's!%%OpenSMTPD%%!$(opensmtpd)!' $(bindir)/$<.new >$(bindir)/$<
	sed -e 's!%%sysconfdir%%!$(sysconfdir)!' $(bindir)/$< >$(bindir)/$<.new
	sed -e 's!%%OFFICIAL%%!$(official)!' $(bindir)/$<.new >$(bindir)/$<
	$(RM) $(bindir)/$<.new
	$(CHMOD) 755 $(bindir)/$<

install-sysconf: postinst postrm preinst prerm
	$(INSTALL) -d $(sysconfsubdir)/etc/default
	$(INSTALL) etc/default/opensmtpd $(sysconfsubdir)/etc/default
	$(INSTALL) -d $(sysconfsubdir)/etc/init.d
	$(INSTALL) etc/init.d/opensmtpd $(sysconfsubdir)/etc/init.d
	$(INSTALL) -d $(sysconfsubdir)/usr/share/doc/opensmtpd
	$(INSTALL) -m 644 usr/share/doc/opensmtpd/* \
		$(sysconfsubdir)/usr/share/doc/opensmtpd
	$(INSTALL) -d $(sysconfsubdir)/usr/share/lintian/overrides
	$(INSTALL) -m 644 usr/share/lintian/overrides/opensmtpd \
		$(sysconfsubdir)/usr/share/lintian/overrides
	$(INSTALL) $^ $(sysconfsubdir)

uninstall: uninstall-bin uninstall-sysconf

uninstall-bin: create-opensmtpd-deb.sh
	$(RM) -f $(bindir)/$<
	-$(RMDIR) -p --ignore-fail-on-non-empty $(bindir)

uninstall-sysconf:
	$(RM) -fr $(sysconfsubdir)
	-$(RMDIR) -p --ignore-fail-on-non-empty $(sysconfdir)

.PHONY: all install uninstall

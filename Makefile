ifeq ($(OPENSMTPD),)
	opensmtpd=$(HOME)/usr/src/OpenSMTPD
else
	opensmtpd=$(OPENSMTPD)
endif

ifeq ($(PACKAGES),)
	packages=/srv/http/caterva.org/apt/.packages
else
	packages=$(PACKAGES)
endif

prefix=$(DESTDIR)/usr/local
exec_prefix=$(prefix)
bindir=$(exec_prefix)/bin
sysconfdir=$(prefix)/etc
sysconfsubdir=$(sysconfdir)/OpenSMTPD-deb

INSTALL=install
RM=rm
RMDIR=rmdir
MV=mv

all:

install: install-bin install-sysconf

install-bin: create-opensmtpd-deb.sh
	$(INSTALL) -d $(bindir)
	$(INSTALL) $< $(bindir)
	sed -e 's!%%packages%%!$(packages)!' $(bindir)/$< >$(bindir)/$<.new
	sed -e 's!%%OpenSMTPD%%!$(opensmtpd)!' $(bindir)/$<.new >$(bindir)/$<
	sed -e 's!%%sysconfdir%%!$(sysconfdir)!' $(bindir)/$< >$(bindir)/$<.new
	$(MV) $(bindir)/$<.new $(bindir)/$<

install-sysconf: postinst postrm preinst prerm
	$(INSTALL) -d $(sysconfsubdir)/etc/default
	$(INSTALL) etc/default/opensmtpd $(sysconfsubdir)/etc/default
	$(INSTALL) -d $(sysconfsubdir)/etc/init.d
	$(INSTALL) etc/init.d/opensmtpd $(sysconfsubdir)/etc/init.d
	$(INSTALL) -d $(sysconfsubdir)/usr/share/doc/opensmtpd
	$(INSTALL) usr/share/doc/opensmtpd/* \
		$(sysconfsubdir)/usr/share/doc/opensmtpd
	$(INSTALL) -d $(sysconfsubdir)/usr/share/lintian/overrides
	$(INSTALL) usr/share/lintian/overrides/opensmtpd \
		$(sysconfsubdir)/usr/share/lintian/overrides
	$(INSTALL) $^ $(sysconfsubdir)

uninstall: uninstall-bin uninstall-sysconf

uninstall-bin: create-opensmtpd-deb.sh
	$(RM) -f $(bindir)/$<
	-$(RMDIR) -p $(bindir)

uninstall-sysconf:
	$(RM) -fr $(sysconfsubdir)
	-$(RMDIR) -p $(sysconfdir)

.PHONY: all install uninstall

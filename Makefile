.PHONY: install uninstall

INSTALL=install
RM=rm
scriptdir=$(DESTDIR)$(exec_prefix)/bin

install: create-opensmtpd-deb.sh
	test -d $(scriptdir) || mkdir $(scriptdir)
	$(INSTALL) $< $(scriptdir)

uninstall: create-opensmtpd-deb.sh
	$(RM) -f $(scriptdir)/$<

.PHONY: install uninstall

INSTALL=install
RM=rm
idir=$(DESTDIR)$(exec_prefix)/bin
locOpenSMTPD=$(shell cat location-OpenSMTPD)
locpackages=$(shell cat location-packages)

install: create-opensmtpd-deb.sh
	test -d $(idir) || mkdir $(idir)
	$(INSTALL) $< $(idir)
	sed -e 's!%%packages%%!$(locpackages)!' $(idir)/$< > $(idir)/$<.new
	sed -e 's!%%OpenSMTPD%%!$(locOpenSMTPD)!' $(idir)/$<.new > $(idir)/$<
	$(RM) -f $(idir)/$<.new

uninstall: create-opensmtpd-deb.sh
	$(RM) -f $(idir)/$<

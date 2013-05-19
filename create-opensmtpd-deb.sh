#!/bin/sh


editor="$EDITOR"
EDITOR="sed -i -r -e '/^(Vendor: |License: ).*$/d'"

fpm -ef -s dir -t deb -n opensmtpd -v git-20130519121309 -C ~/tmp/installdir \
	-p opensmtpd-VERSION_ARCH.deb \
	-d "adduser" \
	-d "libc6 (>= 2.13-38)" \
	-d "libdb5.1" \
	-d "libevent-2.0-5 (>= 2.0.19-stable)" \
	-d "libevent-core-2.0-5 (>= 2.0.19-stable)" \
	-d "libevent-openssl-2.0-5 (>= 2.0.19-stable)" \
	-d "libssl1.0.0 (>= 1.0.1e-2)" \
	-d "zlib1g (>= 1:1.2.7)" \
	-m "David J. Weller-Fahy <dave@weller-fahy.com>" \
	--category mail \
	--config-files /etc/smtpd.conf \
	--provides mail-transport-agent \
	--conflicts mail-transport-agent \
	--replaces mail-transport-agent \
	--url https://github.com/poolpOrg/OpenSMTPD \
	--description "Simple Mail Transfer Protocol daemon
This is the portable version of OpenSMTPD, a FREE implementation of the
server-side SMTP protocol as defined by RFC 5321, with some additional
standard extensions. It allows ordinary machines to exchange e-mails
with other systems speaking the SMTP protocol." \
	.

EDITOR="$editor"

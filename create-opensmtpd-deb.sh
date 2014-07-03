#!/bin/sh
set -e

# Set directory variables.
sdir="%%OpenSMTPD%%"
pdir="%%packages%%"
edir="%%sysconfdir%%/OpenSMTPD-deb"
tdir="$(mktemp -d --tmpdir=$HOME/tmp)"
idir="$tdir/installdir"

mkdir -p "$pdir"

# Check to see if the most recent commit is new by comparing timestamp with
# previously built packages.
cd "$sdir"
git pull -q
cdate=$(git log -n 1 --date=iso --format=%ci)
version=$(date --date="$cdate" -u +%Y%m%d%H%M%S)"-gitp"
test ! -f "$pdir"/opensmtpd-${version}_amd64.deb

# At this point, the package doesn't exist: announce the package version so
# it shows up at the top of the cron email.
echo -n Building OpenSMTPD debian package based on git repository
echo with latest commit:
echo
git log -n 1
echo

# Build everything.
./bootstrap
./configure --prefix=/usr --sysconfdir=/etc \
	CFLAGS="$(dpkg-buildflags --get CFLAGS)" \
	CPPFLAGS="$(dpkg-buildflags --get CPPFLAGS)" \
	CXXFLAGS="$(dpkg-buildflags --get CXXFLAGS)" \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"
make clean
make
mkdir "$idir"
make install DESTDIR="$idir"

# Place files in etc.
mkdir -p "$idir"/etc/init.d
cp "$edir"/etc/init.d/opensmtpd "$idir"/etc/init.d/opensmtpd

# Place files in usr.
mkdir -p "$idir"/usr/share/doc/opensmtpd
cp "$edir"/usr/share/doc/opensmtpd/* "$idir"/usr/share/doc/opensmtpd/
mkdir -p "$idir"/usr/share/lintian/overrides
cp "$edir"/usr/share/lintian/overrides/opensmtpd \
	"$idir"/usr/share/lintian/overrides

# Add README file from the git repository.
cp "$sdir"/README.md "$idir"/usr/share/doc/opensmtpd/
gzip -9 "$idir"/usr/share/doc/opensmtpd/README.md

# Add and rename LICENSE file from the git repository.
cp "$sdir"/LICENSE "$idir"/usr/share/doc/opensmtpd/copyright

# Add a changelog for the snapshot.
cat <<EOF > "$idir"/usr/share/doc/opensmtpd/changelog.Debian
opensmtpd ($version) wheezy; urgency=low

  * new snapshot

 -- An Author  $(date -R)
EOF
gzip -9 "$idir"/usr/share/doc/opensmtpd/changelog.Debian

# Strip executables.
find "$idir"/usr -type f -executable -exec strip {} \;

# Compress man pages.
find "$idir"/usr/share/man/man? -type f -exec gzip -9 {} \;

env EDITOR="sed -i -r -e '/^(Vendor: |License: ).*$/d'" /usr/local/bin/fpm \
		-ef -s dir -t deb -n opensmtpd -v "$version" -C "$idir" \
		-p "$pdir"/opensmtpd-VERSION_ARCH.deb \
		-d "libc6" \
		-d "libdb5.3" \
		-d "libevent-2.0-5" \
		-d "libpam0g" \
		-d "libssl1.0.0" \
		-d "zlib1g" \
		-d "debconf | debconf-2.0" \
		-d "adduser" \
		-m "David J. Weller-Fahy <dave@weller-fahy.com>" \
		--deb-user root \
		--deb-group root \
		--category mail \
		--config-files /etc/init.d/opensmtpd \
		--config-files /etc/smtpd.conf \
		--after-install "$edir"/postinst \
		--before-install "$edir"/preinst \
		--after-remove "$edir"/postrm \
		--before-remove "$edir"/prerm \
		--provides mail-transport-agent \
		--conflicts mail-transport-agent \
		--replaces mail-transport-agent \
		--url https://github.com/OpenSMTPD/OpenSMTPD \
		--description "Simple Mail Transfer Protocol daemon
This is the portable version of OpenSMTPD, a FREE implementation of the
server-side SMTP protocol as defined by RFC 5321, with some additional
standard extensions. It allows ordinary machines to exchange e-mails
with other systems speaking the SMTP protocol." \
		.

rm -r "$tdir"

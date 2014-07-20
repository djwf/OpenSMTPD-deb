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
./configure --prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/lib/x86_64-linux-gnu \
	CFLAGS="$(dpkg-buildflags --get CFLAGS)" \
	CPPFLAGS="$(dpkg-buildflags --get CPPFLAGS)" \
	CXXFLAGS="$(dpkg-buildflags --get CXXFLAGS)" \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"
make clean
make
mkdir "$idir"
make install DESTDIR="$idir"

# Remove mailq link.
rm -f "$idir"/usr/sbin/mailq

# Add sendmail link.
cd "$idir"/usr/sbin
ln -s smtpctl sendmail
cd "$sdir"

# Place files in etc.
mkdir -p "$idir"/etc/init.d
cp "$edir"/etc/init.d/opensmtpd "$idir"/etc/init.d/opensmtpd

# Change config file location of aliases.
patch "$idir"/etc/smtpd.conf < "$edir"/10_smtpd.conf.diff

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

# Create directories in the /var heirarchy.
mkdir -p "$idir"/var/lib/opensmtpd/empty
mkdir -p -m 711 "$idir"/var/spool/smtpd
mkdir -p -m 1777 "$idir"/var/spool/smtpd/offline

env EDITOR="sed -i -r -e '/^(Vendor: |License: ).*$/d'" /usr/local/bin/fpm \
		-ef -s dir -t deb -n opensmtpd -v "$version" -C "$idir" \
		-p "$pdir"/opensmtpd-VERSION_ARCH.deb \
		-d "libasr" \
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
		--deb-config "$edir"/config \
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
		--description "OpenSMTPD portable
This is a snapshot of the OpenSMTPD git repository portable branch: it is not
stable and should not be used unless you want your mail server to break." \
		.

rm -r "$tdir"

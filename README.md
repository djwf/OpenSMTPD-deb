# OpenSMTPD-deb

Automatically build OpenSMTPD debian packages.

## Usage

Install OpenSMTPD-deb, clone OpenSMTPD git repository.

    git clone -b portable git://github.com/poolpOrg/OpenSMTPD.git

Add a cron job to run create-opensmtpd-deb.sh as your desired interval, here 15
minutes is used.  Note that this can be done as a normal user.

    */15 * * * * /usr/local/bin/create-opensmtpd-deb.sh

## Installation

Installation presumes you cloned the OpenSMTPD repository in your personal `src`
directory, and want all built packages placed in your personal `tmp` directory.
Installation and uninstallation respect `DESTDIR`.

    git clone git://github.com/sinecure/OpenSMTPD-deb.git
    cd OpenSMTPD-deb
    echo '~/usr/src/OpenSMTPD' > location-OpenSMTPD
    echo '~/tmp' > location-packages
    make
    make install

## Uninstallation

    cd OpenSMTPD-deb
    make uninstall

## Contribute

* Source code: <https://github.com/sinecure/OpenSMTPD-deb>
* Issue tracker: <https://github.com/sinecure/OpenSMTPD-deb/issues>
* Wiki: <https://github.com/sinecure/OpenSMTPD-deb/wiki>

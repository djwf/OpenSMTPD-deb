# OpenSMTPD-deb

Automatically build an OpenSMTPD debian package.

## Usage

Install OpenSMTPD-deb, then clone the OpenSMTPD git repository.

    git clone -b portable git://github.com/OpenSMTPD/OpenSMTPD.git OpenSMTPD

Add a cron job to run create-opensmtpd-deb.sh at your desired interval, here 15
minutes is used.  Note that this can be done as a normal user.

    */15 * * * * /usr/local/bin/create-opensmtpd-deb.sh

## Defaults

Both installation and uninstallation respect DESTDIR.

    OpenSMTPD official repo:    ~/usr/src/OpenSMTPD
    Package directory:          ~/usr/debian-packages
    DESTDIR:                    ~

## Installation

    git clone git://github.com/sinecure/OpenSMTPD-deb.git
    cd OpenSMTPD-deb
    make install

## Uninstallation

Uninstallation does not touch your repositories (debian packages or OpenSMTPD)
or your package directory.

    cd OpenSMTPD-deb
    make uninstall

## Examples

To change the packages placement directory.

    make install PACKAGES=~/packages

## Contribute

* Source code: <https://github.com/sinecure/OpenSMTPD-deb>
* Issue tracker: <https://github.com/sinecure/OpenSMTPD-deb/issues>
* Wiki: <https://github.com/sinecure/OpenSMTPD-deb/wiki>

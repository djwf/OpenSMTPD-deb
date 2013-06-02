# OpenSMTPD-deb

Automatically build OpenSMTPD debian packages.

## Usage

Install OpenSMTPD-deb, clone OpenSMTPD-portable git repository.

    git clone git://github.com/poolpOrg/OpenSMTPD-portable.git

Set the location of the OpenSMTPD-portable repository on disk.

    echo '~/usr/src/OpenSMTPD-portable' > OpenSMTPD-portable-location

Set the destination of the debian packages.

    echo '~/tmp/OpenSMTPD-debs' > OpenSMTPD-debs-location

Add a cron job to run create-opensmtpd-deb.sh as your desired interval, here 15
minutes is used.  Note that this can be done as a normal user.

    */15 * * * * /usr/local/bin/create-opensmtpd-deb.sh

## Installation

### From source

    git clone git://github.com/sinecure/OpenSMTPD-deb.git
    cd OpenSMTPD-deb && make && sudo make install

## Contribute

* Source code: <https://github.com/sinecure/OpenSMTPD-deb>
* Issue tracker: <https://github.com/sinecure/OpenSMTPD-deb/issues>
* Wiki: <https://github.com/sinecure/OpenSMTPD-deb/wiki>

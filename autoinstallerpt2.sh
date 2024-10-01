doas openssl req -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=$OPENSSL_C/ST=$OPENSSL_ST/L=$OPENSSL_L/O=<$OPENSSL_O/OU=$OPENSSL_OU/CN=$OPENSSL_CN/emailAddress=$OPENSSL_EMAILADDRESS" -keyout /etc/ssl/private/server.key -out /etc/ssl/server.crt
doas /etc/rc.d/httpd -f start
doas rcctl enable httpd
doas ln -sf /usr/local/bin/pip3.6 /usr/local/bin/pip
doas ln -s /usr/local/bin/python3.6 /usr/local/bin/python
doas pkg_add -v py-virtualenv
doas mkdif /usr/local/virtualenvs
doas virtualenv -ppython3 /usr/local/virtualenvs/MISP
doas mkdir /usr/local/src
doas chown misp:misp /usr/local/src
cd /usr/local/src
git clone https://github.com/ssdeep-project/ssdeep.git
cd ssdeep
./bootstrap
./configure --prefix=/usr
make
doas make install
doas pkg_add -v apache-httpd
doas pkg_add -v fcgi-cgi fcgi
doas pkg_add -v php-mysqli php-pcntl php-pdo_mysql php-apache pecl70-redis
cd /etc/php-7.0
doas cp ../php-7.0.sample/* .
doas ln -s /usr/local/bin/php-7.0 /usr/local/bin/php
doas ln -s /usr/local/bin/phpize-7.0 /usr/local/bin/phpize
doas ln -s /usr/local/bin/php-config-7.0 /usr/local/bin/php-config
doas rcctl enable php70_fpm
doas rcctl enable redis
doas /etc/rc.d/redis start
doas /usr/local/bin/mysql_install_db
doas rcctl set mysqld status on
doas rcctl set mysqld flags --bind-address=127.0.0.1
doas /etc/rc.d/mysqld start
doas mysql_secure_installation
# Download MISP using git in the /usr/local/www/ directory.
doas mkdir /var/www/htdocs/MISP
doas chown www:www /var/www/htdocs/MISP
cd /var/www/htdocs/MISP
doas -u www git clone https://github.com/MISP/MISP.git /var/www/htdocs/MISP
doas -u www git submodule update --init --recursive
# Make git ignore filesystem permission differences for submodules
doas -u www git submodule foreach --recursive git config core.filemode false

# Make git ignore filesystem permission differences
doas -u www git config core.filemode false

doas pkg_add py-pip py3-pip libxml libxslt py3-jsonschema
doas /usr/local/virtualenvs/MISP/bin/pip install -U pip

cd /var/www/htdocs/MISP/app/files/scripts
doas -u www git clone https://github.com/CybOXProject/python-cybox.git
doas -u www git clone https://github.com/STIXProject/python-stix.git
cd /var/www/htdocs/MISP/app/files/scripts/python-cybox
doas /usr/local/virtualenvs/MISP/bin/python setup.py install
cd /var/www/htdocs/MISP/app/files/scripts/python-stix
doas /usr/local/virtualenvs/MISP/bin/python setup.py install

# install mixbox to accommodate the new STIX dependencies:
cd /var/www/htdocs/MISP/app/files/scripts/
doas -u www git clone https://github.com/CybOXProject/mixbox.git
cd /var/www/htdocs/MISP/app/files/scripts/mixbox
doas /usr/local/virtualenvs/MISP/bin/python setup.py install

# install PyMISP
cd /var/www/htdocs/MISP/PyMISP
doas /usr/local/virtualenvs/MISP/bin/python setup.py install

# install support for STIX 2.0
doas /usr/local/virtualenvs/MISP/bin/pip install stix2

# install python-magic, pydeep and maec
doas /usr/local/virtualenvs/MISP/bin/pip install python-magic
doas /usr/local/virtualenvs/MISP/bin/pip install git+https://github.com/kbandla/pydeep.git
doas /usr/local/virtualenvs/MISP/bin/pip install maec
# CakePHP is included as a submodule of MISP and has been fetched earlier.
# Install CakeResque along with its dependencies if you intend to use the built in background jobs:
cd /var/www/htdocs/MISP/app
mkdir /var/www/.composer ; chown www:www /var/www/.composer
doas -u www php composer.phar require kamisama/cake-resque:4.1.2
doas -u www php composer.phar config vendor-dir Vendor
doas -u www php composer.phar install

# To use the scheduler worker for scheduled tasks, do the following:
doas -u www cp -f /var/www/htdocs/MISP/INSTALL/setup/config.php /var/www/htdocs/MISP/app/Plugin/CakeResque/Config/config.php
# Check if the permissions are set correctly using the following commands:
doas chown -R www:www /var/www/htdocs/MISP
doas chmod -R 750 /var/www/htdocs/MISP
doas chmod -R g+ws /var/www/htdocs/MISP/app/tmp
doas chmod -R g+ws /var/www/htdocs/MISP/app/files
doas chmod -R g+ws /var/www/htdocs/MISP/app/files/scripts/tmp

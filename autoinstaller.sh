doas pkg_add -v mariadb-server
doas pkg_add -v curl git python redis libmagic autoconf automake libtool
doas pkg_add -v gnupg
doas ln -s /usr/local/bin/gpg2 /usr/local/bin/gpg
doas pkg_add -v postfix
doas /usr/local/sbin/postfix-enable
doas pkg_add -v neovim
doas mv /usr/bin/vi /usr/bin/vi-`date +%d%m%y`
doas ln -s /usr/local/bin/nvim /usr/bin/vi
echo "echo -n ' ntpdate'" |doas tee -a /etc/rc.local
echo "/usr/local/sbin/ntpdate -b pool.ntp.org >/dev/null" |doas tee -a /etc/rc.local
doas rcctl enable xntpd
doas rcctl set xntpd flags "-p /var/run/ntpd.pid"
doas /usr/local/sbin/ntpd -p /var/run/ntpd.pid
doas rcctl enable xntpd
doas rcctl set xntpd flags "-p /var/run/ntpd.pid"
doas /usr/local/sbin/ntpd -p /var/run/ntpd.pid
doas useradd -m -s /usr/local/bin/bash -G wheel,www misp
doas cp /etc/examples/httpd.conf /etc

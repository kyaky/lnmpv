#!/bin/bash
get_char()

	{

	SAVEDSTTY=`stty -g`

	stty -echo

	stty cbreak

	dd if=/dev/tty bs=1 count=1 2> /dev/null

	stty -raw

	stty echo

	stty $SAVEDSTTY

	}

clear
echo "========================================================================="
echo "One key install Varnish Nginx PHP MySQL Memcached APC for Debian"
echo "========================================================================="
echo "Made by Extreme"
echo "My Blog:http://yzs.me/"
echo "For more information please visit http://yzs.me/1517.html"
echo "========================================================================="
echo "If your system is Debian.Press any key to start install.Or press Ctrl+C to quit."
	char=`get_char`
installdir=$(pwd)
apt-get -y install debian-keyring debian-archive-keyring
rm -rf /etc/apt/sources.list.d/dotdeb.list
echo "deb http://packages.dotdeb.org squeeze all" >> /etc/apt/sources.list.d/dotdeb.list
echo "deb-src http://packages.dotdeb.org squeeze all" >> /etc/apt/sources.list.d/dotdeb.list
apt-key add ~/lnmpv/packages/dotdeb.gpg
rm -rf /etc/apt/sources.list.d/backports.list
echo "deb http://backports.debian.org/debian-backports squeeze-backports main" >> /etc/apt/sources.list.d/backports.list
apt-get -y update
apt-get -y install mysql-server
apt-get -y install php5-fpm php-pear php5-dev php5-mysql php-apc php5-mcrypt php5-curl php5-memcache memcached php5-gd
apt-get -yt squeeze-backports install varnish
listen=$(cat /etc/php5/fpm/pool.d/www.conf|grep 127.0.0.1:9000)
sed -i "s/$listen/listen = \/var\/run\/php5-fpm.sock/g" /etc/php5/fpm/pool.d/www.conf
cd ~/lnmpv/scripts/
sh nginx.sh
mkdir /etc/nginx/fastcgi_cache -p
mkdir /etc/nginx/rewrite -p
mkdir /var/www -p
touch /var/log/nginx/default.access.log
touch /var/log/nginx/manager.log
sh $installdir/addmanager
sed -i "/SCRIPT_FILENAME/a\
fastcgi_param   PHP_VALUE               \"open_basedir=\$document_root:/proc/:/tmp/\";" /etc/nginx/fastcgi_params
cd /var/www
apt-get -y install zip
unzip ~/lnmpv/packages/tz.zip
sed -i 's/listen       80;/listen       127.0.0.1:888;/g' /etc/nginx/nginx.conf
mv /etc/varnish/default.vcl /etc/varnish/default.vcl.bak
cd $installdir
cp varnish /etc/varnish/default.vcl
cp addhost /usr/sbin/addhost
cp lnmpv /usr/sbin/lnmpv
cp lnmpv-deletesites.sh /usr/sbin/deletesite
cp delcache /usr/sbin/delcache
chmod +x /usr/sbin/lnmpv
chmod +x /usr/sbin/addhost
chmod +x /usr/sbin/deletesite
chmod +x /usr/sbin/delcache
service varnish stop
sed -i 's/-a :6081/-a :80/g' /etc/default/varnish
sed -i 's/-s malloc,256m/-s malloc,1G/g' /etc/default/varnish
sed -i '1i\service memcached stop;memcached -d -m 128 -p 11211 -u nobody -l localhost' /etc/rc.local
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php5/fpm/php.ini
pmmaxchildren=$(cat /etc/php5/fpm/pool.d/www.conf|grep "pm.max_children =")
pmmaxspareservers=$(cat /etc/php5/fpm/pool.d/www.conf|grep "pm.max_spare_servers =")
sed -i "s/$pmmaxchildren/pm.max_children = 25/g" /etc/php5/fpm/pool.d/www.conf
sed -i "s/$pmmaxspareservers/pm.max_spare_servers = 20/g" /etc/php5/fpm/pool.d/www.conf
sed -i "s/user = www-data/user = php-fpm/g" /etc/php5/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = php-fpm/g" /etc/php5/fpm/pool.d/www.conf
service nginx restart
service varnish start
service php5-fpm restart
service memcached stop
memcached -d -m 128 -p 11211 -u nobody -l localhost
sh last

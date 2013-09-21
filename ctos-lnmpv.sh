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
echo "One key install Varnish Nginx PHP MySQL Memcached APC for CentOS 6.*"
echo "========================================================================="
echo "Made by Extreme"
echo "My Blog:http://yzs.me/"
echo "For more information please visit http://www.mke2fs.com"
echo "========================================================================="
echo "If your system is Centos 6.X. Press any key to start install.Or press Ctrl+C to quit."
	char=`get_char`
installdir=$(pwd)
	echo "==========================="

	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
	echo "==========================="
	echo "MySQL root password:$mysqlrootpwd"
	echo "==========================="
yum makecache
yum -y install mysql-server
rpm --nosignature -i http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.noarch.rpm
yum -y install php-fpm php-mbstring php-pear php-devel php-mysql php-pecl-apc php-mcrypt php-curl php-pecl-memcache memcached varnish php-gd make
listen=$(cat /etc/php-fpm.d/www.conf|grep 127.0.0.1:9000)
sed -i "s/$listen/listen = \/var\/run\/php5-fpm.sock/g" /etc/php-fpm.d/www.conf
useradd -s /bin/sh -d /var/www www-data

cd ~/scripts/
sh nginx-ctos.sh
mkdir /etc/nginx/fastcgi_cache -p
mkdir /etc/nginx/rewrite -p
mkdir /var/www -p
mkdir /tmp/nginx/cache/fcgi
chown -R www-data:www-data /tmp/nginx/
touch /var/log/nginx/default.access.log
touch /var/log/nginx/manager.log
sh $installdir/addmanager
sed -i "/SCRIPT_FILENAME/a\
fastcgi_param   PHP_VALUE               \"open_basedir=\$document_root:/proc/:/tmp/\";" /etc/nginx/fastcgi_params
cd ~/packages/
tar zxvf libmcrypt-2.5.8.tar.gz
cd llibmcrypt-2.5.8
./configure
make
make install
ln -sf /usr/local/lib/libmcrypt.so.4 /lib64/libmcrypt.so.4
ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /lib/libmcrypt.so.4
bit=$(getconf LONG_BIT)
if [ "$bit" == '64' ]; then
cd ~/packages/
rpm -ivh php-mcrypt-5.3.3-1.el6.x86_64.rpm --nodeps
fi
if [ "$bit" == '32' ]; then
cd ~/packages/
rpm -ivh php-mcrypt-5.3.3-1.el6.i686.rpm --nodeps
fi
cd /var/www
yum -y install zip
unzip ~/packages/tz.zip
sed -i 's/listen       80;/listen       127.0.0.1:888;/g' /etc/nginx/nginx.conf
mv /etc/varnish/default.vcl /etc/varnish/default.vcl.bak
cd $installdir
cp varnish /etc/varnish/default.vcl
cp addhost-ctos /usr/sbin/addhost -a
cp lnmpv /usr/sbin/lnmpv -a
cp lnmpv-deletesites.sh /usr/sbin/deletesite
cp delcache /usr/sbin/delcache
chmod +x /usr/sbin/lnmpv
chmod +x /usr/sbin/addhost
chmod +x /usr/sbin/deletesite
chmod +x /usr/sbin/delcache
service varnish stop
chown -R root:php-fpm /var/lib/php/session
sed -i 's/VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/g' /etc/sysconfig/varnish
sed -i 's/VARNISH_STORAGE="file,${VARNISH_STORAGE_FILE},${VARNISH_STORAGE_SIZE}"/VARNISH_STORAGE="malloc,${VARNISH_STORAGE_SIZE}"/g' /etc/sysconfig/varnish
sed -i '1i\service memcached stop;memcached -d -m 128 -p 11211 -u nobody -l localhost' /etc/rc.local
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
sed -i 's/user = apache/user = php-fpm/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = php-fpm/g' /etc/php-fpm.d/www.conf
pmmaxspareservers=$(cat /etc/php-fpm.d/www.conf|grep "pm.max_spare_servers =")
sed -i "s/$pmmaxspareservers/pm.max_spare_servers = 20/g" /etc/php-fpm.d/www.conf
service mysqld restart
mysqladmin -u root password $mysqlrootpwd
pkill nginx
pkill php-fpm
service nginx start
pkill varnishd
service varnish start
service php-fpm start
service mysqld restart
memcached -d -m 128 -p 11211 -u nobody -l localhost
#Fix auto run
mv /etc/rc3.d/K10varnish /etc/rc3.d/S17varnish
mv /etc/rc3.d/K10varnishlog /etc/rc3.d/S17varnishlog
mv /etc/rc3.d/K10varnishncsa /etc/rc3.d/S17varnishncsa
mv /etc/rc3.d/K16php-fpm /etc/rc3.d/S17php-fpm
mv /etc/rc3.d/K36mysqld /etc/rc3.d/S18mysqld
#Some useful
sed -i "/client_max_body_size/i\
\ \ \ \ port_in_redirect off;" /etc/nginx/nginx.conf
#Begin Check
echo "=========================================================="
echo "Check the installation files."
echo "=========================================================="
echo "Check PHP-FPM files"
test -f /etc/php-fpm.conf && echo -e "\033[5m\033[32mPHP-FPM successfully installed.\033[0m"||echo -e "\033[5m\033[31mPHP-FPM installation failed.\033[0m"
echo "Check MySQL files"
test -f /usr/bin/mysql && echo -e "\033[5m\033[32mMySQL successfully installed.\033[0m"||echo -e "\033[5m\033[31mMySQL installation failed.\033[0m"     
echo "Check Nginx flise"
test -d /etc/nginx && echo -e "\033[5m\033[32mNginx successfully installed.\033[0m"||echo -e "\033[5m\033[31mNginx installation failed.\033[0m"
echo "Check Varnish flies"
test -d /etc/varnish && echo -e "\033[5m\033[32mVarnish successfully installed.\033[0m"||echo -e "\033[5m\033[31mVarnish installation failed.\033[0m"
echo "Check Memcached files"
test -f /usr/bin/memcached && echo -e "\033[5m\033[32mMemcached successfully installed.\033[0m"||echo -e "\033[5m\033[31mMemcached installation failed.\033[0m"
echo "=========================================================="
echo "Check the LNMPV status."
echo "=========================================================="
phpfpmrun=$(ps aux|grep "php-fpm"|grep -v "grep"|head -1)
mysqlrun=$(ps aux|grep "mysql"|grep -v "grep"|head -1)
nginxrun=$(ps aux|grep "nginx"|grep -v "grep"|head -1)
varnishrun=$(ps aux|grep "varnish"|grep -v "grep"|head -1)
memcachedrun=$(ps aux|grep "memcached"|grep -v "grep"|head -1)
echo "Check PHP-FPM Status"
if [ "$phpfpmrun" = "" ];then
        echo -e "\033[5m\033[31mPHP-FPM failed to start.\033[0m"
        error=1
else
        echo -e "\033[5m\033[32mPHP-FPM successfully started.\033[0m"
fi
echo "Check MySQL Status"
if [ "$mysqlrun" = "" ];then
        echo -e "\033[5m\033[31mMySQL failed to start.\033[0m"
        error=1
else
        echo -e "\033[5m\033[32mMySQL successfully started.\033[0m"
fi
echo "Check Nginx Status"
if [ "$nginxrun" = "" ];then
        echo -e "\033[5m\033[31mNginx failed to start.\033[0m"
        error=1
else
        echo -e "\033[5m\033[32mNginx successfully started.\033[0m"
fi
echo "Check Varnish Status"
if [ "$varnishrun" = "" ];then
        echo -e "\033[5m\033[31mVarnish failed to start.\033[0m"
        error=1
else
        echo -e "\033[5m\033[32mVarnish successfully started.\033[0m"
fi
echo "Check Memcached Status"
if [ "$memcachedrun" = "" ];then
        echo -e "\033[5m\033[31mMemcached failed to start.\033[0m"
        error=1
else
        echo -e "\033[5m\033[32mMemcached successfully started.\033[0m"
fi
if [ "$error" = "1" ];then
        echo -e "\033[46;30mThere are some errors when installed LNMPV,please sent the log files to e@yzs.me.\033[0m"
else
        echo -e "\033[46;30mLNMPV successfully installed and successfully started.\033[0m"
	echo "You can visit http:///yourserverip:8910/tz.php"
	echo "phpMyAdmin:http://yourserverip:8910/phpmyadmin/"
	echo "Made by Extreme"
	echo "My Blog:http://yzs.me/"
	echo "For more information please visit http://www.mke2fs.com"
fi

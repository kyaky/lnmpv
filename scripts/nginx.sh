apt-get install zip unzip libxslt1-dev libxml2-dev libpcre3-dev libjpeg62-dev autoconf libxml2-dev libcurl4-openssl-dev openssl libpng12-dev libmcrypt-dev curl gcc g++ make libssl-dev libgeoip-dev -y
apt-get install make libssl-dev libpcre3-dev libxml2-dev libxslt1-dev libxml2-dev libgd2-xpm libgd2-xpm-dev -y
cd ~
cd ~/lnmpv/packages/
tar zxvf LuaJIT-2.0.1.tar.gz
rm -rf LuaJIT-2.0.1.tar.gz
cd LuaJIT-2.0.1
make
make install
ln -sf luajit-2.0.0-beta10 /usr/local/bin/luajit
ln -sf /usr/local/lib/libluajit-5.1.so.2 /usr/lib/
cd ~
cd ~/lnmpv/packages/
tar zxvf GeoIP-latest.tar.gz
rm -rf GeoIP-latest.tar.gz
cd GeoIP*
./configure
make
make install
ln -s /usr/local/lib/libGeoIP.so.1 /lib
cd ~
cd ~/lnmpv/packages/
tar zxvf nginx-1.4.2.tar.gz
cd nginx-1.4.2

cp ~/lnmpv/packages/ngx_http_substitutions_filter_module-master.zip ./ngx_http_substitutions_filter_module.zip
cp ~/lnmpv/packages/ngx_devel_kit-master.zip ./ngx_devel_kit.zip
cp ~/lnmpv/packages/lua-nginx-module-master.zip ./lua-nginx-module.zip
cp ~/lnmpv/packages/limit_req2_nginx_module-master.zip ./limit_req2_nginx_module.zip

unzip ngx_http_substitutions_filter_module.zip
unzip ngx_devel_kit.zip
unzip lua-nginx-module.zip
unzip limit_req2_nginx_module.zip
rm -rf ngx_http_substitutions_filter_module.zip ngx_devel_kit.zip lua-nginx-module.zip limit_req2_nginx_module.zip
./configure --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-pcre-jit --with-debug --with-file-aio --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_realip_module --with-http_secure_link_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-mail --with-mail_ssl_module  --add-module=$(pwd)/ngx_http_substitutions_filter_module-master --add-module=$(pwd)/ngx_devel_kit-master --add-module=$(pwd)/lua-nginx-module-master --add-module=$(pwd)/limit_req2_nginx_module-master
make
make install
mkdir /var/lib/nginx/body -p
ln -sf /usr/share/nginx/sbin/nginx /usr/sbin/nginx
cp -f ~/lnmpv/addons/nginx-lnmpv.conf /etc/nginx/nginx.conf
mkdir /etc/nginx/sites-available
mkdir /tmp/nginx/cache/path -p
chown -R www-data:www-data /tmp/nginx/
sed -i '1i\mkdir /tmp/nginx/cache/path -p;chown -R www-data:www-data /tmp/nginx/;service nginx restart' /etc/rc.local
cp -f ~/lnmpv/addons/fastcgi_params /etc/nginx/fastcgi_params
cp -f ~/lnmpv/addons/nginx /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
ln -sf /etc/init.d/nginx /etc/rc3.d/S85nginx

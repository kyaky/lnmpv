apt-get -y --purge autoremove mysql-server* php* memcached* varnish*
service nginx stop
service memcached stop
service varnish stop
service mysql stop
apt-get -f install

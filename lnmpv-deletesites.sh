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


sites=$(ls /etc/nginx/sites-available/|awk '{print $NF}'|grep -v '000-manager*')
echo "$sites"
        echo "==========================="
        deletesite=""
        echo "Which site do you want to delete."
	while [ "$deletesite" = "" ]; do
        read -p"The site:"  deletesite
done
        echo "==========================="
        echo "The site you want to delete:$deletesite"
        echo "==========================="
	echo "Press any key to continue."
	char=`get_char`
rm -rf /etc/nginx/sites-available/$deletesite
rm -rf /etc/nginx/rewrite/$deletesite
rm -rf /etc/nginx/fastcgi_cache/$deletesite
rm -rf /etc/nginx/fastcgi_cache/$deletesite
rm -rf /etc/php5/fpm/pool.d/$deletesite
rm -rf /etc/php-fpm.d/$deletesite
/etc/init.d/php*-fpm restart
service nginx restart
service varnish restart
echo "Complete."

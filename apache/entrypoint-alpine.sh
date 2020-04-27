#!/usr/bin/env bash

# Apache server name change
if [ ! -z "$APACHE_SERVER_NAME" ]
	then
		sed -i "s/#ServerName www.example.com:80/ServerName $APACHE_SERVER_NAME/" /etc/apache2/httpd.conf
		echo "Changed server name to '$APACHE_SERVER_NAME'..."
	else
		echo "NOTICE: Change 'ServerName' globally and hide server message by setting environment variable >> 'APACHE_SERVER_NAME=your.server.name' in docker command or docker-compose file"
fi

# PHP Config
if [ ! -z "$PHP_MAX_EXECUTION_TIME" ]; then echo "max_execution_time = $PHP_MAX_EXECUTION_TIME" >> /usr/local/etc/php/conf.d/custom.ini && echo "Set PHP max_execution_time = $PHP_MAX_EXECUTION_TIME..."; fi
if [ ! -z "$PHP_MEMORY_LIMIT" ]; then echo "memory_limit = $PHP_MEMORY_LIMIT" >> /usr/local/etc/php/conf.d/custom.ini && echo "Set PHP memory_limit = $PHP_MEMORY_LIMIT..."; fi
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then echo "post_max_size = $PHP_POST_MAX_SIZE" >> /usr/local/etc/php/conf.d/custom.ini && echo "Set PHP post_max_size = $PHP_POST_MAX_SIZE..."; fi
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then echo "upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE" >> /usr/local/etc/php/conf.d/custom.ini && echo "Set PHP upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE..."; fi
if [ ! -z "$PHP_MAX_FILE_UPLOADS" ]; then echo "max_file_uploads = $PHP_MAX_FILE_UPLOADS" >> /usr/local/etc/php/conf.d/custom.ini && echo "Set PHP max_file_uploads = $PHP_MAX_FILE_UPLOADS..."; fi

# Start (ensure apache2 PID not left behind first) to stop auto start crashes if didn't shut down properly
echo "Clearing any old processes..."
rm -f /run/apache2/apache2.pid
rm -f /run/apache2/httpd.pid

echo "Starting apache..."
httpd -D FOREGROUND
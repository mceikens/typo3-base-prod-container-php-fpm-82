#!/bin/sh
set -e
exec php-fpm --fpm-config /usr/local/etc/php-fpm.conf

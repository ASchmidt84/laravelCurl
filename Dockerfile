 
FROM eboraas/apache-php
MAINTAINER André Schmidt 

RUN apt-get update && apt-get -y install \
git \
curl \
libcurl3 \
libcurl3-dev \
php5-mcrypt \
php5-json \
php5-curl \
php5-redis \
imagemagick \
php5-gd \
php5-cli \
php5-geoip \
php5-imagick \
php5-imap \
php5-xcache \
&& apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN /usr/sbin/a2enmod rewrite

ADD 000-laravel.conf /etc/apache2/sites-available/
ADD 001-laravel-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-laravel 001-laravel-ssl

RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
RUN /bin/mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer self-update
RUN /usr/local/bin/composer create-project laravel/laravel /var/www/laravel --prefer-dist
RUN /bin/chown www-data:www-data -R /var/www/laravel/storage /var/www/laravel/bootstrap/cache

RUN cd /var/www/laravel
RUN /usr/local/bin/composer require torann/geoip
RUN /usr/local/bin/composer require geoip2/geoip2
RUN /usr/local/bin/composer require maxmind-db/reader

#RUN /usr/bin/php /var/www/laravel/artisan geoip:update

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
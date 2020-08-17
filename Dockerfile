FROM php:7

RUN apt-get update

# Install modules : GD mcrypt iconv
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        openssl libssh-dev \
        libnghttp2-dev \
        libhiredis-dev \
    && pecl install mcrypt-1.0.2 && docker-php-ext-enable mcrypt \
    && docker-php-ext-install iconv  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# memcached module	
RUN apt-get install -y libmemcached-dev unzip \
    && yes "" | pecl install -f memcached-3.1.1
#RUN curl -o /root/memcached.zip https://github.com/php-memcached-dev/php-memcached/archive/php7.zip -L && \
#RUN curl -o /root/memcached.zip https://github.com/php-memcached-dev/php-memcached/archive/2.2.0.zip -L
 cd /root && unzip memcached.zip && rm memcached.zip && \
# cd php-memcached-2.2.0 && \
 cd php-memcached-php7 && \
 phpize && ./configure --enable-sasl && make && make install && \
 cd /root && rm -rf /root/php-memcached-* && \
 echo "extension=memcached.so" > /usr/local/etc/php/conf.d/memcached.ini  && \
 echo "memcached.use_sasl = 1" >> /usr/local/etc/php/conf.d/memcached.ini 


# install php pdo_mysql opcache
RUN docker-php-ext-install pdo_mysql mysqli iconv mbstring json  opcache 
# WARNING: Disable opcache if you run you php
RUN echo "opcache.enable_cli=0" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# install dom xml
#RUN apt-get install libxml2 && docker-php-ext-install dom simplexml xmlreader
# install php curl
#RUN apt-get install libcurl && docker-php-ext-install curl

# memcached module with sasl
#RUN curl -o /root/libmemcached.tgz https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
#RUN cd /root && tar zxvf libmemcached.tgz && cd libmemcached-1.0.18 && \
# ./configure --enable-sasl && make && make install && \
# cd /root && rm -rf /root/libmemcached* 

# install swoole
#RUN pecl install swoole
RUN cd /root && pecl download swoole && \
    tar -zxvf swoole-1* && cd swoole-1* && \
    phpize && \
    ./configure --enable-openssl  --enable-http2  --enable-async-redis && \
    make && make install 
RUN docker-php-ext-enable swoole

#install redis
# 
#ENV PHPREDIS_VERSION php7
#RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
#    && tar xfz /tmp/redis.tar.gz \
#    && rm -r /tmp/redis.tar.gz \
#    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
#    && docker-php-ext-install redis
RUN pecl install redis && docker-php-ext-enable redis

# log to /var/www/log
# RUN mkdir -p /var/www/log
# RUN echo "error_log = /var/www/log/php_error.log" > /usr/local/etc/php/conf.d/log.ini
RUN echo "log_errors = On" >> /usr/local/etc/php/conf.d/log.ini \
    && echo "error_log=/dev/stderr" >> /usr/local/etc/php/conf.d/log.ini


# add user additional conf for apache & php
# add to CMD mkdir -p /var/www/conf/php && mkdir -p /var/www/conf/apache2 &&
# RUN echo "" >> /usr/local/php/conf.d/additional.ini
# RUN echo "" >> /etc/apache2/conf-enabled/additional.conf

# set system timezone & php timezone
# @TODO



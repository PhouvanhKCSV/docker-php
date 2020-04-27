#https://github.com/prooph/docker-files/blob/master/php/7.4-fpm
FROM php:7.4.5-zts-alpine3.11

ENV PHPIZE_DEPS \
    autoconf \
    cmake \
    file \
    g++ \
    gcc \
    libc-dev \
    pcre-dev \
    make \
    git \
    pkgconf \
    re2c \
    # for GD
    freetype-dev \
    libpng-dev  \
    libjpeg-turbo-dev \
    # for intl extension
    icu-dev

RUN apk apk update && apk add --no-cache --virtual .persistent-deps \
    bash \
    tzdata \
    # for composer
    gnu-libiconv \
    # for oci
    libnsl \
    libaio \
    # for intl extension
    icu-libs \
    # for soap
    libxml2-dev \
    # for GD
    freetype \
    libpng \
    libjpeg-turbo \
    # for mbstring
    oniguruma-dev \
    # for zip
    libzip-dev

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS

RUN cp /usr/share/zoneinfo/Asia/Vientiane /etc/localtime \
    && echo "Asia/Vientiane" > /etc/timezone

# FIX WORK ICONV LIBRARY WITH ALPHINE (requried gnu-libiconv)
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.1 --install-dir=/usr/local/bin --filename=composer

# INSTALL OCI (requried libnsl, libaio)
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
ENV ORACLE_HOME=/opt/oracle/instantclient

COPY ../files/instantclient-basic-linux.x64-12.1.0.2.0.zip /opt/oracle/
COPY ../files/instantclient-sdk-linux.x64-12.1.0.2.0.zip /opt/oracle/

RUN unzip /opt/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle/ \
    && unzip /opt/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle/ \
    && mv /opt/oracle/instantclient_12_1 /opt/oracle/instantclient \
    && ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so \
    && ln -s /opt/oracle/instantclient/libocci.so.12.1 /opt/oracle/instantclient/libocci.so \
    && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 \
    && rm -rf /opt/oracle/*.zip

RUN echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8 \
    && docker-php-ext-enable oci8 \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient,12.1 \
    && docker-php-ext-install -j$(nproc) pdo_oci

RUN docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure mysqli --with-mysqli \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        pcntl \
        mysqli \
        pdo_mysql \
        mbstring \
        soap \
        sockets \
        iconv \ 
        xmlrpc \
        zip

# ENV PHP_REDIS_VERSION 5.2.1
# RUN git clone --branch ${PHP_REDIS_VERSION} https://github.com/phpredis/phpredis /tmp/phpredis \
#         && cd /tmp/phpredis \
#         && phpize  \
#         && ./configure  \
#         && make  \
#         && make install \
#         && make test

RUN apk add --no-cache apache2

# POST INSTALLATION
RUN apk del .build-deps \
    && rm -rf /tmp/* \
    && rm -f /var/cache/apk/*

# CONFIG PHP
RUN echo "date.timezone = Asia/Vientiane" >> /usr/local/etc/php/conf.d/custom.ini \
    && sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/public\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/var/www#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/var/www\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

COPY entrypoint-alpine.sh /sbin/
RUN chmod +x /sbin/entrypoint-alpine.sh \
    && chown -R apache:apache /var/www \
    && chmod -R 755 /var/www

WORKDIR /var/www

EXPOSE 80
ENTRYPOINT ["/sbin/entrypoint-alpine.sh"]

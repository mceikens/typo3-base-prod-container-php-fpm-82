#######################
# Build Stage
#######################
FROM alpine:3.20 AS build

ENV PHP_VERSION=8.2.30

RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    bison \
    build-base \
    curl \
    curl-dev \
    tar \
    xz \
    icu-dev \
    libxml2-dev \
    libzip-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    gmp-dev \
    bzip2-dev \
    gettext-dev \
    libxslt-dev \
    openssl-dev \
    sqlite-dev \
    libffi-dev \
    zlib-dev \
    readline-dev \
    imap-dev \
    krb5-dev \
    imagemagick \
    imagemagick-dev \
    libwebp-dev \
    libheif-dev \
    librsvg-dev \
    ghostscript \
    libc-dev \
    argon2-dev \
    && update-ca-certificates

# PHP source download & extraction
RUN curl -fsSL https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz -o php.tar.xz \
    && mkdir -p /usr/src/php \
    && tar -xf php.tar.xz -C /usr/src/php --strip-components=1 \
    && rm php.tar.xz

# Build PHP
RUN cd /usr/src/php \
    && ./configure \
        --prefix=/usr/local \
        --enable-fpm \
        --enable-bcmath \
        --enable-calendar \
        --enable-exif \
        --enable-ftp \
        --enable-gd \
        --enable-intl \
        --enable-mbstring \
        --enable-opcache \
        --enable-pcntl \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --enable-zts \
        --enable-fileinfo \
        --enable-dom \
        --enable-simplexml \
        --enable-xmlreader \
        --enable-xmlwriter \
        --enable-session \
        --with-xsl \
        --with-zip \
        --with-zlib \
        --with-openssl \
        --with-readline \
        --with-imap \
        --with-imap-ssl \
        --with-pdo-mysql \
        --with-password-argon2 \
        --with-gettext \
        --with-gmp \
        --with-jpeg \
        --with-freetype \
        --with-mysqli \
        --with-bz2 \
        --with-curl \
        --with-gd \
        --with-jpeg \
        --with-freetype \
        --with-webp \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --with-config-file-path=/usr/local/lib \
        --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    && make -j$(nproc) \
    && make install \
    && cp php.ini-production /usr/local/lib/php.ini \
    && curl -O https://pear.php.net/go-pear.phar \
    && /usr/local/bin/php go-pear.phar \
    && rm go-pear.phar

# Imagick PHP Extension installieren
RUN pecl install imagick redis
ENV PHP_EXT_DIR=/usr/local/lib/php/extensions/no-debug-zts-*
RUN mkdir -p /usr/local/etc/php/conf.d && \
    for ext in \
      imagick \
      redis; do \
      echo "extension=${ext}.so" >> /usr/local/etc/php/conf.d/20-${ext}.ini; \
    done

# Copy custom configs
COPY /config/php.ini /usr/local/lib/php.ini
COPY /config/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY /config/www.conf /usr/local/etc/php-fpm.d/www.conf


#######################
# Runtime Stage
#######################
FROM alpine:3.20

# System libraries
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    autoconf \
    bison \
    make \
    gcc \
    g++ \
    curl \
    curl-dev \
    tar \
    xz \
    icu-dev \
    libxml2-dev \
    libzip-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    gmp-dev \
    bzip2-dev \
    gettext-dev \
    libxslt-dev \
    openssl-dev \
    sqlite-dev \
    libffi-dev \
    zlib-dev \
    readline-dev \
    imap-dev \
    krb5-dev \
    supervisor \
    shadow \
    tini \
    imagemagick \
    imagemagick-dev \
    libwebp \
    libde265 \
    dav1d \
    librsvg \
    libheif \
    ghostscript \
    libc-dev \
    argon2-libs

# Copy PHP & extensions from build
COPY --from=build /usr/local /usr/local

# Set www-data user
RUN addgroup -S www-data || true \
 && adduser -S -G www-data www-data || true

# Entrypoint
COPY ./entrypoint/docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /usr/share/nginx/html/app

EXPOSE 9000



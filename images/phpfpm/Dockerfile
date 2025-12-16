FROM php:8.3-fpm-alpine
LABEL maintainer="Michael Büchner <m.buechner@dnb.de>"

ARG LS_ZIP_URL="https://download.limesurvey.org/latest-master/limesurvey6.16.3+251215.zip"

RUN apk add --no-cache \
    curl unzip icu-dev zlib-dev libzip-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    oniguruma-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" intl pdo_mysql mysqli mbstring xml gd zip opcache

# runtime temp in /tmp (für readOnlyRootFilesystem)
RUN { \
    echo "short_open_tag=On"; \
    echo "upload_tmp_dir=/tmp"; \
    echo "session.save_path=/tmp"; \
    } > /usr/local/etc/php/conf.d/99-limesurvey.ini

# LimeSurvey nach /var/www/html
RUN mkdir -p /var/www/html \
    && curl -fsSL "$LS_ZIP_URL" -o /tmp/limesurvey.zip \
    && unzip -q /tmp/limesurvey.zip -d /tmp/ls \
    && ( [ -d /tmp/ls/limesurvey ] && mv /tmp/ls/limesurvey/* /var/www/html/ || mv /tmp/ls/* /var/www/html/ ) \
    && rm -rf /tmp/ls /tmp/limesurvey.zip \
    && mkdir -p /var/www/html/upload /var/www/html/tmp /var/www/html/application/config

# OpenShift Arbitrary UID Support:
# - group 0 als „shared“ group
# - g=u, damit beliebige UID (mit passender group) schreiben kann
RUN chgrp -R 0 /var/www/html \
    && chmod -R g=u /var/www/html

# PHP-FPM: keine festen user/group Direktiven (OpenShift läuft als random UID)
# Listen auf TCP 9000 (kein Socket-Dateisystem nötig)
RUN sed -i \
    -e 's|^listen = .*|listen = 9000|' \
    -e 's|^user = .*|;user =|' \
    -e 's|^group = .*|;group =|' \
    /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html
EXPOSE 9000

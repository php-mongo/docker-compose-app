FROM php:7.3.28-apache-stretch

ARG WITH_XDEBUG=false
ARG WITH_XDEBUG_PROFILE=false

# Basic requirements also include mongod
RUN apt-get update -y \
    && apt-get install \
      libxml2-dev \
      libjpeg-dev \
      libpng-dev \
      libfreetype6-dev \
      libpq-dev \
      autoconf \
      gcc \
      coreutils \
      g++ \
      make \
      git \
      unzip \
      libcurl4-openssl-dev \
      pkg-config \
      libssl-dev\
    && apt-get clean -y \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} \
        calendar \
        ctype \
        bcmath \
        exif \
        fileinfo \
        soap \
        gd \
        mysqli \
        opcache \
        initl \
        pdo_mysql \
        mbstring \
        tokenizer \
        zip \
        gettext \
        sqlite \
        pdo_sqlite \
        json \
        mongodb \
        openssl \
        pdo \
        xml

# Install composer - taken from composer dockerfile
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

# For composer v1 a handy tool to get multiple packes at the same time
#RUN composer global require hirak/prestissimo

# Copy the php.ini file
COPY ./config/php.ini-development /usr/local/etc/php.ini

# Copy the web host configuration
COPY ./config/phpMongoAdmin.conf /etc/apache2/conf-available/
RUN ln -s /etc/apache2/conf-available/phpMongoAdmin.conf /etc/apache2/conf-enabled/phpMongoAdmin.conf

# Include xdebug
RUN pecl install xdebug

# Allow connections to mongodb
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb;

# Optional: redis for planned caching improvements
#RUN pecl install -D 'enable-redis-igbinary="no" enable-redis-lxf="no" enable-redis-zstd="no"' redis
#RUN docker-php-ext-enable redis;

# The entrypont willsetup xdebug if needed
#COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN chmod 777 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN if [ $WITH_XDEBUG = "true"] ; then \
    docker-php-ext-enable xdebug; \
    echo "xdebug.profiler_enabled=1" >> /user/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "display_startup_errors = On" >> /usr/local/etc/php/docker-php-ext-xdebug.ini; \
    echo "display_errors = On" >> /usr/local/etc/php/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/docker-php-ext-xdebug.ini; \
fi;

# Setup xdebug profiler if required
RUN if [ $WITH_XDEBUG = "true"] && [ $WITH_XDEBUG_PROFILE = "true" ]; then \
    echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/docker-php-ext-xdebug.ini; \
    echo "xdebug.profiler_output_dir=\"/tmp/xdebug/\"" >> /usr/local/etc/php/docker-php-ext-xdebug.ini; \
fi;

# Set the working directory to make it easier to enter
WORKDIR /usr/share/phpMongoAdmin

# Copy any user scripts to the container
COPY ./scripts/*.sh /tmp/scripts/

ENV BASH_ENV /etc/profile

# Add bash helpers and extras. A bit of magic to tie everything together
RUN mkdir -p /tmp/scripts/ \
    && touch /tmp/scripts/profile.sh \
    && chmod +x /tmp/scripts/* \
    && cp /tmp/scripts/profile.sh /etc/profile.d/ \
    && echo ". /etc/profile" >> !/.bashrc



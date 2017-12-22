FROM alpine:edge
# Key for PHP packages @see https://github.com/codecase/php-alpine
RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --update \
    bash \
    less \
    vim \
    sudo \
    nano \
    php7-cli \
    php7-json \
    php7-zlib \
    php7-xml \
    php7-pdo \
    php7-phar \
    php7-openssl \
    php7-pdo_mysql \
    php7-mysqli \
    php7-session \
    php7-gd \
    php7-iconv \
    php7-mcrypt \
    php7-curl \
    php7-opcache \
    php7-ctype \
    php7-apcu \
    php7-intl \
    php7-bcmath \
    php7-mbstring \
    php7-dom \
    php7-xmlreader \
    php7-gettext \
    openssh-client \
    git \
    curl \
    wget \
    rsync \
    musl \
    tar \
    autoconf \
    automake \
    binutils \
    binutils-libs \
    build-base \
    file \
    fortify-headers \
    g++ \
    gcc \
    gdbm \
    gmp \
    sqlite-libs \
    yaml \
    zlib-dev \
    gmp-dev \
    http-parser \
    isl \
    libatomic \
    libc-dev \
    libffi \
    libgmpxx \
    libgomp \
    libintl \
    libjpeg-turbo-utils \
    libmagic \
    libuv \
    m4 \
    make \
    mpc1 \
    mpfr3 \
    musl-dev \
    nasm \
    nodejs \
    openssh-keygen \
    perl \
    pkgconf \
    python2 \
    ruby \
    ruby-dev \
    ruby-irb \
    ruby-libs \
    ruby-rdoc \
    sqlite-libs \
    sqlite-dev \
    yaml \
    zlib-dev && \
    gem install mailcatcher && \
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini && \
    ln -sf /usr/bin/php7 /usr/bin/php

## Add normal user with passwordless sudo
RUN addgroup -S accuser \
    && adduser -S -s /bin/bash -h /home/accuser -G accuser accuser \
    && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo 'accuser:secret' | chpasswd


## Run the following as the privileged user
USER accuser

## Install composer
RUN cd /home/accuser
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

## Install wp-cli
RUN cd /home/accuser \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && sudo mv wp-cli.phar /usr/local/bin/wp \
    && wp --info

CMD "echo 'Codeception server started'"
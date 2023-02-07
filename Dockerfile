FROM ubuntu:jammy

# Disable Prompts During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
ARG ACCEPT_EULA=Y
# Set the version number - in the build process, Jenkins will pass this in as a --build-arg
ARG app_version=
ENV APP_VERSION=${app_version}
# SSH Key to read ICNET bitbucket dependencies repos
ARG SSH_KEY
ARG SSH_KEY_PASSPHRASE=
# Set PHP version
ARG php=8.1
ENV LC_ALL en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV DB_ROOT_PASSWORD=root
ENV APOC_VERSION 4.3.0.6
ENV APOC_URI https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/${APOC_VERSION}/apoc-${APOC_VERSION}-all.jar
RUN \
    apt-get update &&\
    apt-get -y --no-install-recommends install wget lsb-release ca-certificates apt-transport-https locales apt-utils gnupg curl software-properties-common &&\
    add-apt-repository ppa:ondrej/php -y &&\
    add-apt-repository ppa:ondrej/apache2 -y &&\
    apt-get update &&\
    # jammy not yet available
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - &&\
    echo 'deb https://debian.neo4j.com stable 4.4' | tee -a /etc/apt/sources.list.d/neo4j.list &&\
    echo "neo4j-enterprise neo4j/question select I ACCEPT" | debconf-set-selections &&\
    echo "neo4j-enterprise neo4j/license note" | debconf-set-selections &&\
    echo "deb http://httpredir.debian.org/debian buster-backports main" | tee -a /etc/apt/sources.list.d/buster-backports.list &&\
    echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen &&\
    locale-gen en_GB.UTF-8 &&\
    /usr/sbin/update-locale LANG=en_GB.UTF-8 &&\
    apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29 &&\
    apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 &&\
    apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 &&\
    wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb &&\
    dpkg -i libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb &&\

    wget http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb &&\
    dpkg -i libffi6_3.2.1-8_amd64.deb &&\

    wget http://mirrors.edge.kernel.org/ubuntu/pool/main/libw/libwebp/libwebp6_0.6.1-2ubuntu0.20.04.1_amd64.deb &&\
    dpkg -i libwebp6_0.6.1-2ubuntu0.20.04.1_amd64.deb &&\

    wget http://security.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_2.1.2-0ubuntu1_amd64.deb &&\
    dpkg -i libjpeg-turbo8_2.1.2-0ubuntu1_amd64.deb &&\
    wget http://ge.archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg8-empty/libjpeg8_8c-2ubuntu10_amd64.deb &&\
    dpkg -i libjpeg8_8c-2ubuntu10_amd64.deb &&\

    apt-get update &&\
    apt-get -y --no-install-recommends install git \
    libjpeg-turbo8-dev \
    libjpeg-turbo8 \
    php$php-mysql \
    php$php-cli \
    php$php-dom \
    php$php-sqlite3 \
    php$php-curl \
    php$php-intl \
    php$php-gd \
    php$php-mbstring \
    php$php-xmlrpc \
    php$php-zip \
    php-memcached \
    php-geoip \
    php-apcu \
    php-imagick \
    php-xdebug \
    imagemagick \
    openjdk-11-jre-headless \
    openssh-client \
    software-properties-common \
    patch \
    gettext \
    zip \
    unzip \
    apt-transport-https \
    neo4j-enterprise \
    memcached &&\
    update-alternatives --set php /usr/bin/php$php &&\
    neo4j-admin set-initial-password password &&\
    wget $APOC_URI && mv apoc-${APOC_VERSION}-all.jar /var/lib/neo4j/plugins/apoc-${APOC_VERSION}-all.jar &&\
    chown neo4j.adm /var/lib/neo4j/plugins/apoc-${APOC_VERSION}-all.jar &&\
    service neo4j start &&\
    curl -sSL https://deb.nodesource.com/setup_14.x | bash - &&\
    apt-get -y --no-install-recommends install nodejs &&\
    apt-get autoclean && apt-get clean && apt-get autoremove &&\
    curl -sSL https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin --version=2.5.1 &&\
    curl -sSL https://phar.phpunit.de/phpunit.phar -o /usr/bin/phpunit  && chmod +x /usr/bin/phpunit  &&\
    curl -sSL http://codeception.com/codecept.phar -o /usr/bin/codecept && chmod +x /usr/bin/codecept &&\
    npm install --no-color --production --global gulp-cli webpack mocha grunt eslint &&\
    rm -rf /root/.npm /root/.composer /tmp/* /var/lib/apt/lists/*

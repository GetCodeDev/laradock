#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# To edit the 'php-fpm' base Image, visit its repository on Github
#    https://github.com/Laradock/php-fpm
#
# To change its version, see the available Tags on the Docker Hub:
#    https://hub.docker.com/r/laradock/php-fpm/tags/
#
# Note: Base Image name format {image-tag}-{php-version}
#

ARG LARADOCK_PHP_VERSION

FROM laradock/php-fpm:2.5-${LARADOCK_PHP_VERSION}

LABEL maintainer="Mahmoud Zalt <mahmoud@zalt.me>"

ARG LARADOCK_PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    # Change application source from deb.debian.org to aliyun source
    sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list \
;fi

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
      apt-utils \
      #
      #--------------------------------------------------------------------------
      # Mandatory Software's Installation
      #--------------------------------------------------------------------------
      #
      # Mandatory Software's such as ("mcrypt", "pdo_mysql", "libssl-dev", ....)
      # are installed on the base image 'laradock/php-fpm' image. If you want
      # to add more Software's or remove existing one, you need to edit the
      # base image (https://github.com/Laradock/php-fpm).
      #
      # next lines are here becase there is no auto build on dockerhub see https://github.com/laradock/laradock/pull/1903#issuecomment-463142846
      libzip-dev zip unzip && \
      docker-php-ext-configure zip --with-libzip && \
      # Install the zip extension
      docker-php-ext-install zip && \
      php -m | grep -q 'zip'



#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# Optional Software's will only be installed if you set them to `true`
# in the `docker-compose.yml` before the build.
# Example:
#   - INSTALL_SOAP=true
#

###########################################################################
# Composer:
###########################################################################

USER root

RUN cd /var/www/
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/bin/composer

# Add the composer.json
COPY ./composer.json /home/www-data/.composer/composer.json

# Add the auth.json for magento 2 credentials
COPY ./auth.json /home/www-data/.composer/auth.json

# Make sure that ~/.composer belongs to www-data
RUN chown -R www-data:www-data /home/www-data/.composer

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

# Check if global install need to be ran
ARG COMPOSER_GLOBAL_INSTALL=false
ENV COMPOSER_GLOBAL_INSTALL ${COMPOSER_GLOBAL_INSTALL}

# Check if auth file is disabled
ARG COMPOSER_AUTH=false
ENV COMPOSER_AUTH ${COMPOSER_AUTH}

RUN if [ ${COMPOSER_AUTH} = false ]; then \
    # remove the file
    rm /home/www-data/.composer/auth.json \
;fi

ARG COMPOSER_REPO_PACKAGIST
ENV COMPOSER_REPO_PACKAGIST ${COMPOSER_REPO_PACKAGIST}

RUN if [ ${COMPOSER_REPO_PACKAGIST} ]; then \
    composer config -g repo.packagist composer ${COMPOSER_REPO_PACKAGIST} \
;fi

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Node / NVM:
###########################################################################

# Check if NVM needs to be installed
ARG NODE_VERSION=node
ENV NODE_VERSION ${NODE_VERSION}
ARG INSTALL_NODE=false
ARG INSTALL_NPM_GULP=false
ARG INSTALL_NPM_BOWER=false
ARG INSTALL_NPM_VUE_CLI=false
ARG INSTALL_NPM_ANGULAR_CLI=false
ARG NPM_REGISTRY
ENV NPM_REGISTRY ${NPM_REGISTRY}
ENV NVM_DIR /home/www-data/.nvm

RUN if [ ${INSTALL_NODE} = true ]; then \
    # Install nvm (A Node Version Manager)
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
        && . $NVM_DIR/nvm.sh \
        && nvm install ${NODE_VERSION} \
        && nvm use ${NODE_VERSION} \
        && nvm alias ${NODE_VERSION} \
        && if [ ${NPM_REGISTRY} ]; then \
        npm config set registry ${NPM_REGISTRY} \
        ;fi \
        && if [ ${INSTALL_NPM_GULP} = true ]; then \
        npm install -g gulp \
        ;fi \
        && if [ ${INSTALL_NPM_BOWER} = true ]; then \
        npm install -g bower \
        ;fi \
        && if [ ${INSTALL_NPM_VUE_CLI} = true ]; then \
        npm install -g @vue/cli \
        ;fi \
        && if [ ${INSTALL_NPM_ANGULAR_CLI} = true ]; then \
        npm install -g @angular/cli \
        ;fi \
        && ln -s `npm bin --global` /home/www-data/.node-bin \
;fi

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
;fi

# Add NVM binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/www-data/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
;fi

# Add PATH for node
ENV PATH $PATH:/home/www-data/.node-bin

# Make it so the node modules can be executed with 'docker-compose exec'
# We'll create symbolic links into '/usr/local/bin'.
RUN if [ ${INSTALL_NODE} = true ]; then \
    find $NVM_DIR -type f -name node -exec ln -s {} /usr/local/bin/node \; && \
    NODE_MODS_DIR="$NVM_DIR/versions/node/$(node -v)/lib/node_modules" && \
    ln -s $NODE_MODS_DIR/bower/bin/bower /usr/local/bin/bower && \
    ln -s $NODE_MODS_DIR/gulp/bin/gulp.js /usr/local/bin/gulp && \
    ln -s $NODE_MODS_DIR/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s $NODE_MODS_DIR/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue /usr/local/bin/vue && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-init /usr/local/bin/vue-init && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-list /usr/local/bin/vue-list \
;fi

RUN if [ ${NPM_REGISTRY} ]; then \
    . ~/.bashrc && npm config set registry ${NPM_REGISTRY} \
;fi

###########################################################################
# Non-root user : PHPUnit path
###########################################################################

# add ./vendor/bin to non-root user's bashrc (needed for phpunit)
USER root

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="/var/www/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# SSH2:
###########################################################################

ARG INSTALL_SSH2=false

RUN if [ ${INSTALL_SSH2} = true ]; then \
    # Install the ssh2 extension
    apt-get -y install libssh2-1-dev && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install -a ssh2-0.13; \
    else \
        pecl install -a ssh2-1.1.2; \
    fi && \
    docker-php-ext-enable ssh2 \
;fi

###########################################################################
# libfaketime:
###########################################################################

USER root

ARG INSTALL_FAKETIME=false

RUN if [ ${INSTALL_FAKETIME} = true ]; then \
    apt-get install -y libfaketime \
;fi

###########################################################################
# SOAP:
###########################################################################

ARG INSTALL_SOAP=false

RUN if [ ${INSTALL_SOAP} = true ]; then \
    # Install the soap extension
    rm /etc/apt/preferences.d/no-debian-php && \
    apt-get -y install libxml2-dev php-soap && \
    docker-php-ext-install soap \
;fi

###########################################################################
# XSL:
###########################################################################

ARG INSTALL_XSL=false

RUN if [ ${INSTALL_XSL} = true ]; then \
    # Install the xsl extension
    apt-get -y install libxslt-dev && \
    docker-php-ext-install xsl \
;fi

###########################################################################
# pgsql
###########################################################################

ARG INSTALL_PGSQL=false

RUN if [ ${INSTALL_PGSQL} = true ]; then \
    # Install the pgsql extension
    docker-php-ext-install pgsql \
;fi

###########################################################################
# pgsql client
###########################################################################

ARG INSTALL_PG_CLIENT=false
ARG INSTALL_POSTGIS=false

RUN if [ ${INSTALL_PG_CLIENT} = true ]; then \
    # Create folders if not exists (https://github.com/tianon/docker-brew-debian/issues/65)
    mkdir -p /usr/share/man/man1 && \
    mkdir -p /usr/share/man/man7 && \
    # Install the pgsql client
    apt-get install -y postgresql-client && \
    if [ ${INSTALL_POSTGIS} = true ]; then \
      apt-get install -y postgis; \
    fi \
;fi

###########################################################################
# xDebug:
###########################################################################

ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    pecl install xdebug-2.5.5; \
  else \
    pecl install xdebug; \
  fi && \
  docker-php-ext-enable xdebug \
;fi

# Copy xdebug configuration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /usr/local/etc/php/conf.d/xdebug.ini

###########################################################################
# Phpdbg:
###########################################################################

ARG INSTALL_PHPDBG=false

RUN if [ ${INSTALL_PHPDBG} = true ]; then \
    # Load the xdebug extension only with phpunit commands
    apt-get install -y --force-yes php${LARADOCK_PHP_VERSION}-phpdbg \
;fi

###########################################################################
# Blackfire:
###########################################################################

ARG INSTALL_BLACKFIRE=false

RUN if [ ${INSTALL_XDEBUG} = false -a ${INSTALL_BLACKFIRE} = true ]; then \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
;fi

###########################################################################
# PHP REDIS EXTENSION
###########################################################################

ARG INSTALL_PHPREDIS=false

RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    # Install Php Redis Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install -o -f redis-4.3.0; \
    else \
      pecl install -o -f redis; \
    fi \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
;fi

###########################################################################
# Swoole EXTENSION
###########################################################################

ARG INSTALL_SWOOLE=false

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
    # Install Php Swoole Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install swoole-2.0.10; \
    else \
      if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install swoole-2.2.0; \
      else \
        pecl install swoole; \
      fi \
    fi && \
    docker-php-ext-enable swoole \
    && php -m | grep -q 'swoole' \
;fi

###########################################################################
# Taint EXTENSION
###########################################################################

ARG INSTALL_TAINT=false

RUN if [ ${INSTALL_TAINT} = true ]; then \
    # Install Php TAINT Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
      pecl install taint && \
      docker-php-ext-enable taint && \
      php -m | grep -q 'taint'; \
    fi \
;fi

###########################################################################
# MongoDB:
###########################################################################

ARG INSTALL_MONGO=false

RUN if [ ${INSTALL_MONGO} = true ]; then \
    # Install the mongodb extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install mongo && \
      docker-php-ext-enable mongo \
    ;fi && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb \
;fi

###########################################################################
# Xhprof:
###########################################################################

ARG INSTALL_XHPROF=false

RUN if [ ${INSTALL_XHPROF} = true ]; then \
    # Install the php xhprof extension 
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = 7 ]; then \
      curl -L -o /tmp/xhprof.tar.gz "https://github.com/tideways/php-xhprof-extension/archive/v4.1.7.tar.gz"; \
    else \ 
      curl -L -o /tmp/xhprof.tar.gz "https://codeload.github.com/phacility/xhprof/tar.gz/master"; \
    fi \
    && mkdir -p xhprof \
    && tar -C xhprof -zxvf /tmp/xhprof.tar.gz --strip 1 \
    && ( \
        cd xhprof \
        && phpize \
        && ./configure \
        && make \
        && make install \
    ) \
    && rm -r xhprof \
    && rm /tmp/xhprof.tar.gz \
;fi

COPY ./xhprof.ini /usr/local/etc/php/conf.d

RUN if [ ${INSTALL_XHPROF} = false ]; then \
    rm /usr/local/etc/php/conf.d/xhprof.ini \
;fi

###########################################################################
# AMQP:
###########################################################################

ARG INSTALL_AMQP=false

RUN if [ ${INSTALL_AMQP} = true ]; then \
    # download and install manually, to make sure it's compatible with ampq installed by pecl later
    # install cmake first
    apt-get update && apt-get -y install cmake && \
    curl -L -o /tmp/rabbitmq-c.tar.gz https://github.com/alanxz/rabbitmq-c/archive/master.tar.gz && \
    mkdir -p rabbitmq-c && \
    tar -C rabbitmq-c -zxvf /tmp/rabbitmq-c.tar.gz --strip 1 && \
    cd rabbitmq-c/ && \
    mkdir _build && cd _build/ && \
    cmake .. && \
    cmake --build . --target install && \
    # Install the amqp extension
    pecl install amqp && \
    docker-php-ext-enable amqp && \
    # Install the sockets extension
    docker-php-ext-install sockets \
;fi

###########################################################################
# GEARMAN:
###########################################################################

ARG INSTALL_GEARMAN=false

RUN if [ ${INSTALL_GEARMAN} = true ]; then \
    apt-get update && \
    apt-get -y install libgearman-dev && \
    cd /tmp && \
    curl -L https://github.com/wcgallego/pecl-gearman/archive/gearman-2.0.5.zip -O && \
    unzip gearman-2.0.5.zip && \
    mv pecl-gearman-gearman-2.0.5 pecl-gearman && \
    cd /tmp/pecl-gearman && \
    phpize && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm /tmp/gearman-2.0.5.zip && \
    rm -r /tmp/pecl-gearman && \
    docker-php-ext-enable gearman \
;fi

###########################################################################
# pcntl
###########################################################################

ARG INSTALL_PCNTL=false
RUN if [ ${INSTALL_PCNTL} = true ]; then \
    # Installs pcntl, helpful for running Horizon
    docker-php-ext-install pcntl \
;fi

###########################################################################
# bcmath:
###########################################################################

ARG INSTALL_BCMATH=false

RUN if [ ${INSTALL_BCMATH} = true ]; then \
    # Install the bcmath extension
    docker-php-ext-install bcmath \
;fi

###########################################################################
# GMP (GNU Multiple Precision):
###########################################################################

ARG INSTALL_GMP=false

RUN if [ ${INSTALL_GMP} = true ]; then \
    # Install the GMP extension
	  apt-get install -y libgmp-dev && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    ;fi && \
    docker-php-ext-install gmp \
;fi

###########################################################################
# PHP Memcached:
###########################################################################

ARG INSTALL_MEMCACHED=false

RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
    # Install the php memcached extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install memcached-2.2.0; \
    else \
      pecl install memcached-3.1.3; \
    fi \
    && docker-php-ext-enable memcached \
;fi

###########################################################################
# Exif:
###########################################################################

ARG INSTALL_EXIF=false

RUN if [ ${INSTALL_EXIF} = true ]; then \
    # Enable Exif PHP extentions requirements
    docker-php-ext-install exif \
;fi

###########################################################################
# PHP Aerospike:
###########################################################################

USER root

ARG INSTALL_AEROSPIKE=false

RUN set -xe; \
    if [ ${INSTALL_AEROSPIKE} = true ]; then \
    # Fix dependencies for PHPUnit within aerospike extension
    apt-get -y install sudo wget && \
    # Install the php aerospike extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      curl -L -o /tmp/aerospike-client-php.tar.gz https://github.com/aerospike/aerospike-client-php5/archive/master.tar.gz; \
    else \
      curl -L -o /tmp/aerospike-client-php.tar.gz https://github.com/aerospike/aerospike-client-php/archive/master.tar.gz; \
    fi \
    && mkdir -p /tmp/aerospike-client-php \
    && tar -C /tmp/aerospike-client-php -zxvf /tmp/aerospike-client-php.tar.gz --strip 1 \
    && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      ( \
          cd /tmp/aerospike-client-php/src/aerospike \
          && phpize \
          && ./build.sh \
          && make install \
      ) \
    else \
      ( \
          cd /tmp/aerospike-client-php/src \
          && phpize \
          && ./build.sh \
          && make install \
      ) \
    fi \
    && rm /tmp/aerospike-client-php.tar.gz \
    && docker-php-ext-enable aerospike \
;fi

###########################################################################
# IonCube Loader:
###########################################################################

ARG INSTALL_IONCUBE=false

RUN if [ ${INSTALL_IONCUBE} = true ]; then \
    # Install the php ioncube loader
    curl -L -o /tmp/ioncube_loaders_lin_x86-64.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar zxpf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /tmp \
    && mv /tmp/ioncube/ioncube_loader_lin_${LARADOCK_PHP_VERSION}.so $(php -r "echo ini_get('extension_dir');")/ioncube_loader.so \
    && printf "zend_extension=ioncube_loader.so\n" > $PHP_INI_DIR/conf.d/0ioncube.ini \
    && rm -rf /tmp/ioncube* \
;fi

###########################################################################
# Opcache:
###########################################################################

ARG INSTALL_OPCACHE=false

RUN if [ ${INSTALL_OPCACHE} = true ]; then \
    docker-php-ext-install opcache \
;fi

# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

###########################################################################
# Mysqli Modifications:
###########################################################################

ARG INSTALL_MYSQLI=false

RUN if [ ${INSTALL_MYSQLI} = true ]; then \
    docker-php-ext-install mysqli \
;fi


###########################################################################
# Human Language and Character Encoding Support:
###########################################################################

ARG INSTALL_INTL=false

RUN if [ ${INSTALL_INTL} = true ]; then \
    # Install intl and requirements
    apt-get install -y zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl \
;fi

###########################################################################
# GHOSTSCRIPT:
###########################################################################

ARG INSTALL_GHOSTSCRIPT=false

RUN if [ ${INSTALL_GHOSTSCRIPT} = true ]; then \
    # Install the ghostscript extension
    # for PDF editing
    apt-get install -y \
    poppler-utils \
    ghostscript \
;fi

###########################################################################
# LDAP:
###########################################################################

ARG INSTALL_LDAP=false

RUN if [ ${INSTALL_LDAP} = true ]; then \
    apt-get install -y libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap \
;fi

###########################################################################
# SQL SERVER:
###########################################################################

ARG INSTALL_MSSQL=false

RUN set -eux; \
  if [ ${INSTALL_MSSQL} = true ]; then \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      apt-get -y install freetds-dev libsybdb5 \
      && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
      && docker-php-ext-install mssql pdo_dblib \
      && php -m | grep -q 'mssql' \
      && php -m | grep -q 'pdo_dblib' \
    ;else \
      ###########################################################################
      # Ref from https://github.com/Microsoft/msphpsql/wiki/Dockerfile-for-adding-pdo_sqlsrv-and-sqlsrv-to-official-php-image
      ###########################################################################
      # Add Microsoft repo for Microsoft ODBC Driver 13 for Linux
      apt-get install -y apt-transport-https gnupg \
      && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
      && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
      && apt-get update -yqq \
      # Install Dependencies
      && ACCEPT_EULA=Y apt-get install -y unixodbc unixodbc-dev libgss3 odbcinst msodbcsql17 locales \
      && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
      # link local aliases
      && ln -sfn /etc/locale.alias /usr/share/locale/locale.alias \
      && locale-gen \
      # Install pdo_sqlsrv and sqlsrv from PECL. Replace pdo_sqlsrv-4.1.8preview with preferred version.
      && if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install pdo_sqlsrv-5.3.0 sqlsrv-5.3.0 \
      ;else \
        pecl install pdo_sqlsrv sqlsrv \
      ;fi \
      && docker-php-ext-enable pdo_sqlsrv sqlsrv \
      && php -m | grep -q 'pdo_sqlsrv' \
      && php -m | grep -q 'sqlsrv' \
    ;fi \
  ;fi

###########################################################################
# Image optimizers:
###########################################################################

USER root

ARG INSTALL_IMAGE_OPTIMIZERS=false

RUN if [ ${INSTALL_IMAGE_OPTIMIZERS} = true ]; then \
    apt-get install -y jpegoptim optipng pngquant gifsicle \
;fi

###########################################################################
# ImageMagick:
###########################################################################

USER root

ARG INSTALL_IMAGEMAGICK=false

RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
    apt-get install -y libmagickwand-dev imagemagick && \
    pecl install imagick && \
    docker-php-ext-enable imagick \
;fi

###########################################################################
# IMAP:
###########################################################################

ARG INSTALL_IMAP=false

RUN if [ ${INSTALL_IMAP} = true ]; then \
    apt-get install -y libc-client-dev libkrb5-dev && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap \
;fi

###########################################################################
# Calendar:
###########################################################################

USER root

ARG INSTALL_CALENDAR=false

RUN if [ ${INSTALL_CALENDAR} = true ]; then \
    docker-php-ext-configure calendar && \
    docker-php-ext-install calendar \
;fi

###########################################################################
# Phalcon:
###########################################################################

ARG INSTALL_PHALCON=false
ARG LARADOCK_PHALCON_VERSION
ENV LARADOCK_PHALCON_VERSION ${LARADOCK_PHALCON_VERSION}

# Copy phalcon configration
COPY ./phalcon.ini /usr/local/etc/php/conf.d/phalcon.ini.disable

RUN if [ $INSTALL_PHALCON = true ]; then \
    apt-get update && apt-get install -y unzip libpcre3-dev gcc make re2c \
    && curl -L -o /tmp/cphalcon.zip https://github.com/phalcon/cphalcon/archive/v${LARADOCK_PHALCON_VERSION}.zip \
    && unzip -d /tmp/ /tmp/cphalcon.zip \
    && cd /tmp/cphalcon-${LARADOCK_PHALCON_VERSION}/build \
    && ./install \
    && mv /usr/local/etc/php/conf.d/phalcon.ini.disable /usr/local/etc/php/conf.d/phalcon.ini \
    && rm -rf /tmp/cphalcon* \
;fi

###########################################################################
# APCU:
###########################################################################

ARG INSTALL_APCU=false

RUN if [ ${INSTALL_APCU} = true ]; then \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install -a apcu-4.0.11; \
    else \
        pecl install apcu; \
    fi && \
    docker-php-ext-enable apcu \
;fi

###########################################################################
# YAML:
###########################################################################

USER root

ARG INSTALL_YAML=false

RUN if [ ${INSTALL_YAML} = true ]; then \
    apt-get install libyaml-dev -y ; \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install -a yaml-1.3.2; \
    else \
        pecl install yaml; \
    fi && \
    docker-php-ext-enable yaml \
;fi

###########################################################################
# RDKAFKA:
###########################################################################

ARG INSTALL_RDKAFKA=false

RUN if [ ${INSTALL_RDKAFKA} = true ]; then \
    apt-get install -y librdkafka-dev && \
    pecl install rdkafka && \
    docker-php-ext-enable rdkafka \
;fi

###########################################################################
# Install additional locales:
###########################################################################

ARG INSTALL_ADDITIONAL_LOCALES=false
ARG ADDITIONAL_LOCALES

RUN if [ ${INSTALL_ADDITIONAL_LOCALES} = true ]; then \
    apt-get install -y locales \
    && echo '' >> /usr/share/locale/locale.alias \
    && temp="${ADDITIONAL_LOCALES%\"}" \
    && temp="${temp#\"}" \
    && for i in ${temp}; do sed -i "/$i/s/^#//g" /etc/locale.gen; done \
    && locale-gen \
;fi

###########################################################################
# MySQL Client:
###########################################################################

USER root

ARG INSTALL_MYSQL_CLIENT=false

RUN if [ ${INSTALL_MYSQL_CLIENT} = true ]; then \
    apt-get update -yqq && \
    if [ ${LARADOCK_PHP_VERSION} = "7.3" ]; then \
      apt-get -y install default-mysql-client \
    ;else \
      apt-get -y install mysql-client \
    ;fi \
;fi

###########################################################################
# ping:
###########################################################################

USER root

ARG INSTALL_PING=false

RUN if [ ${INSTALL_PING} = true ]; then \
    apt-get update -yqq && \
    apt-get -y install inetutils-ping \
;fi

###########################################################################
# sshpass:
###########################################################################

USER root

ARG INSTALL_SSHPASS=false

RUN if [ ${INSTALL_SSHPASS} = true ]; then \
    apt-get update -yqq && \
    apt-get -y install sshpass \
;fi

###########################################################################
# FFMPEG:
###########################################################################

USER root

ARG INSTALL_FFMPEG=false

RUN if [ ${INSTALL_FFMPEG} = true ]; then \
    apt-get update -yqq && \
    apt-get -y install ffmpeg \
;fi

###########################################################################
# Mailparse extension:
###########################################################################

ARG INSTALL_MAILPARSE=false

RUN if [ ${INSTALL_MAILPARSE} = true ]; then \
    # Install mailparse extension
    printf "\n" | pecl install -o -f mailparse \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable mailparse \
;fi

###########################################################################
# WKHTMLTOPDF
###########################################################################
ARG INSTALL_WKHTMLTOPDF=false

RUN if [ ${INSTALL_WKHTMLTOPDF} = true ]; then \
 apt-get update && apt-get -y install fontconfig libxext6 libxrender1 xfonts-utils wget \
     libfontenc1 x11-common xfonts-75dpi xfonts-base \
 && curl -L -o /tmp/wkhtmltopdf.deb https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
 && dpkg -i --force-depends /tmp/wkhtmltopdf.deb \
;fi

###########################################################################
# ssh:
###########################################################################


# COPY union /var/www/id_rsa
# COPY union.pub /var/www/id_rsa.pub

# RUN rm -f /etc/service/sshd/down \
#     && mkdir /root/.ssh \
#     # && cat /var/www/id_rsa.pub >> /root/.ssh/authorized_keys \
#         && cat /var/www/id_rsa.pub >> /root/.ssh/id_rsa.pub \
#         && cat /var/www/id_rsa >> /root/.ssh/id_rsa \
# #         && chmod 644 /root/.ssh/authorized_keys /root/.ssh/id_rsa.pub \
#     && chmod 400 /root/.ssh/id_rsa \
#     && cp -rf /root/.ssh /home/www-data \
#     && chown -R www-data /home/www-data/.ssh

#
# RUN rm -f /etc/service/sshd/down\
#         && mkdir ~/.ssh \
#         && cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys \
#         && cat /tmp/id_rsa.pub >> ~/.ssh/id_rsa.pub \
#         && cat /tmp/id_rsa >> ~/.ssh/id_rsa \
#         && chmod 644 ~/.ssh/authorized_keys ~/.ssh/id_rsa.pub \
#         && chmod 400 ~/.ssh/id_rsa

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${LARADOCK_PHP_VERSION}."
#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

USER root

RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get install -y nano

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Adding the faketime library to the preload file needs to be done last
# otherwise it will preload it for all commands that follow in this file
RUN if [ ${INSTALL_FAKETIME} = true ]; then \
    echo "/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1" > /etc/ld.so.preload \
;fi

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000

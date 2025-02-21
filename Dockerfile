FROM alpine:latest

# Install essential packages
RUN apk --update --no-cache add ca-certificates
RUN apk add build-base pcre pcre-dev openssl openssl-dev zlib zlib-dev \
    php7 php7-fpm php7-mcrypt php7-soap php7-openssl php7-gmp php7-pdo_odbc php7-json php7-dom php7-pdo php7-zip php7-mysqli \
    php7-sqlite3 php7-apcu php7-pdo_pgsql php7-bcmath php7-gd php7-odbc php7-pdo_mysql php7-pdo_sqlite php7-gettext php7-xmlreader \
    php7-xmlrpc php7-bz2 php7-iconv php7-pdo_dblib php7-curl php7-ctype php7-phar php7-fileinfo php7-mbstring php7-tokenizer \
    tar wget

# Download and install ionCube Loader
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /tmp/ioncube_loaders.tar.gz \
    && tar -xzf /tmp/ioncube_loaders.tar.gz -C /usr/lib/php \
    && echo "zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_7.4.so" > /etc/php7/php-fpm/conf.d/00-ioncube.ini \
    && rm -rf /tmp/ioncube_loaders.tar.gz

# Download and install Nginx
RUN wget https://nginx.org/download/nginx-1.21.5.tar.gz \
    && tar zxf nginx-1.21.5.tar.gz \
    && cd nginx-1.21.5 \
    && ./configure \
        --with-http_mp4_module \
        --with-http_sub_module \
        --prefix=/var/www/html \
        --sbin-path=/usr/sbin/nginx \
        --http-log-path=/home/container/nginx/access.log \
        --error-log-path=/home/container/nginx/error.log \
        --with-pcre \
        --lock-path=/var/lock/nginx.lock \
        --pid-path=/var/run/nginx.pid \
        --with-http_ssl_module \
        --modules-path=/etc/nginx/modules \
        --with-http_v2_module \
        --with-stream=dynamic \
        --with-http_addition_module \
    && make \
    && make install

# Install certbot for SSL (if needed)
RUN apk add certbot python3-certbot-nginx

USER container
ENV USER container
ENV HOME /home/container

WORKDIR /home/container

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh

# Define default command
CMD ["/bin/ash", "/entrypoint.sh"]

# Imagem base
FROM debian:jessie

MAINTAINER Eduardo Ramos <eduardorfreitas93@gmail.com>

# Install modules
RUN apt-get update && apt-get install -y vim git freetds-dev \
    freetds-bin tdsodbc unixodbc unixodbc-dev ldap-utils \
    imagemagick libmagickwand-dev libpcre3 libpcre3-dev \
    libaio1 php5 php5-fpm php5-mcrypt php5-dev php5-odbc \
    php5-pgsql php5-sqlite php5-sybase php5-ldap php5-apcu \
    php5-redis php5-gearman php5-imagick php5-curl php5-gd php-pear nodejs npm \
    && ln -s /usr/bin/nodejs /usr/bin/node && npm install -g n && n latest \
    && npm install -g gulp && npm install -g phantomjs

# Arquivos de configuração
ADD conf/freetds.conf /etc/freetds/freetds.conf
ADD conf/oci8.so /usr/lib/php5/20131226/oci8.so

# Volume e área de trabalho
VOLUME ["/var/www/html"]
WORKDIR /var/www/html

# Arquivo de instalação do oracle
ADD conf/oracle/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb /tmp
ADD conf/oracle/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb /tmp
ADD conf/oracle/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb /tmp

RUN dpkg -i /tmp/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb \
  	&& dpkg -i /tmp/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb \ 
  	&& dpkg -i /tmp/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb

ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib/
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64/lib/

RUN echo 'instantclient,/usr/lib/oracle/12.1/client64/lib' | pecl install -f oci8-1.4.10 \
	&& echo "extension=oci8.so" > /etc/php5/fpm/conf.d/30-oci8.ini \
	&& sed -i '/daemonize /c daemonize = no' /etc/php5/fpm/php-fpm.conf \
	&& sed -i '/^listen /c listen = 0.0.0.0:9000' /etc/php5/fpm/pool.d/www.conf \
	&& sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php5/fpm/pool.d/www.conf \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Porta aberta
EXPOSE 9000

# Comando de start php-fpm
ENTRYPOINT ["php5-fpm"]

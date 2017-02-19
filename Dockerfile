FROM eboraas/apache-php

MAINTAINER Eduardo Ramos <eduardorfreitas93@gmail.com>

# Install packages
RUN apt-get update && apt-get install -y vim wget freetds-dev \
    freetds-bin tdsodbc unixodbc unixodbc-dev ldap-utils \
    imagemagick libmagickwand-dev libpcre3 libpcre3-dev \
    libaio1 php5-mcrypt php5-dev php5-odbc \
    php5-pgsql php5-sqlite php5-sybase php5-ldap php5-apcu libapache2-mod-php5 \
    php5-redis php5-gearman php5-imagick php5-curl php5-gd php-pear nodejs npm \
    && ln -s /usr/bin/nodejs /usr/bin/node && npm install -g n && n latest \
    && npm install -g gulp && npm install -g phantomjs

ADD conf/freetds.conf /etc/freetds/freetds.conf
ADD conf/run.sh /usr/local/bin/run.sh

VOLUME ["/var/www/html"]
WORKDIR /var/www/html

ADD conf/oracle/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb /tmp
ADD conf/oracle/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb /tmp
ADD conf/oracle/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb /tmp

RUN dpkg -i /tmp/oracle-instantclient12.1-basic_12.1.0.2.0-2_amd64.deb \
  	&& dpkg -i /tmp/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb \ 
  	&& dpkg -i /tmp/oracle-instantclient12.1-sqlplus_12.1.0.2.0-2_amd64.deb

ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib/
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64/lib/
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN echo 'instantclient,/usr/lib/oracle/12.1/client64/lib' | pecl install -f oci8-1.4.10 \
	&& echo "extension=oci8.so" > /etc/php5/apache2/conf.d/30-oci8.ini \
	&& a2enmod rewrite \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& chmod 755 /usr/local/bin/*.sh

CMD ["/usr/local/bin/run.sh"]

FROM eboraas/apache-php

MAINTAINER Eduardo Ramos <eduardorfreitas93@gmail.com>

# Install packages
RUN apt-get update && apt-get install -y wget git freetds-dev \
  freetds-bin tdsodbc unixodbc unixodbc-dev ldap-utils \
  imagemagick libmagickwand-dev libpcre3 libpcre3-dev \
  libaio1 php5 php5-mcrypt php5-dev php5-mysql php5-odbc \
  php5-pgsql php5-sqlite php5-sybase php5-ldap php5-apcu libapache2-mod-php5 \
  php5-redis php5-gearman php5-imagick php5-curl php5-gd php-pear nodejs npm

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g n && n latest
RUN npm install -g gulp
RUN npm install -g phantomjs

ADD conf/freetds.conf /etc/freetds/freetds.conf
ADD conf/run.sh /usr/local/bin/run.sh
RUN chmod 755 /usr/local/bin/*.sh

VOLUME ["/var/www/html"]
WORKDIR /var/www/html

ADD conf/instantclient_12_1 instantclient_12_1

RUN mkdir /usr/lib/oracle
RUN mkdir /usr/lib/oracle/12_1
RUN mkdir /usr/lib/oracle/12_1/client64/
RUN mkdir /usr/lib/oracle/12_1/client64/lib
RUN mv instantclient_12_1/* /usr/lib/oracle/12_1/client64/lib
RUN cd /usr/lib/oracle/12_1/client64/lib
RUN ln -s libclntsh.so.12.1 libclntsh.so
RUN ln -s libocci.so.12.1 libocci.so
RUN ln -s /usr/lib/oracle/12_1/client64/lib/*.so /usr/local/lib/
RUN ln -s /usr/lib/oracle/12_1/client64/lib/*.so.12.1 /usr/local/lib/
RUN export ORACLE_HOME=/usr/lib/oracle/12_1/client64

RUN pecl install oci8-1.4.10

ADD conf/oci8.so /usr/lib/php5/20131226/oci8.so

ADD conf/oci.ini /etc/php5/apache2/conf.d/oci.ini
ADD conf/oci.ini /etc/php5/cli/conf.d/oci.ini
ADD conf/oci.ini /etc/php5/mods-available/conf.d/oci.ini

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/local/bin/run.sh"]

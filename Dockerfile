FROM php:5.6-apache
MAINTAINER Volker Wiegand <volker.wiegand@cvw.de>

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/deliciousbrains/sqlbuddy.git /tmp/sqlbuddy_git \
	&& mkdir /var/lib/sqlbuddy \
	&& mv -v /tmp/sqlbuddy_git/src/* /var/lib/sqlbuddy/ \
	&& rm -rf /tmp/sqlbuddy_git /var/www/html/index.html

ENV APACHE_LOG_DIR /var/log/apache2
RUN a2enmod ssl

ADD ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443

FROM php:5.6-apache
MAINTAINER Volker Wiegand <volker.wiegand@cvw.de>

ENV SERVER_ADMIN root@localhost
ENV SERVER_NAME localhost
ENV DOCUMENT_ROOT /var/www/sqlbuddy

RUN apt-get update && apt-get install -yqq git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/deliciousbrains/sqlbuddy.git /var/www/sqltemp \
	&& mkdir /var/www/sqlbuddy \
	&& mv /var/www/sqltemp/src/* /var/www/sqlbuddy \
	&& rm -rf /var/www/sqltemp

RUN sed -e "s|^ServerAdmin.*|ServerAdmin \${SERVER_ADMIN}|" \
	-e "s|^[#]*ServerName.*|ServerName \${SERVER_NAME}|" \
	-e "s|^DocumentRoot.*|DocumentRoot \${DOCUMENT_ROOT}|" \
	-i /etc/apache2/apache2.conf

EXPOSE 80

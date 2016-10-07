FROM php:5.6-apache
MAINTAINER Volker Wiegand <volker.wiegand@cvw.de>

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
	libpng12-dev \
	libjpeg-dev \
	libpq-dev \
	libxml2-dev \
	vim-tiny \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring mysql mysqli pgsql soap \
	&& rm -rf /var/lib/apt/lists/* /var/www/html/index.html

ENV MANTIS_VER 1.3.2
ENV MANTIS_MD5 f30acb6d41ba757b7c09f922a0f68b06
ENV MANTIS_URL https://sourceforge.net/projects/mantisbt/files/mantis-stable/${MANTIS_VER}/mantisbt-${MANTIS_VER}.tar.gz
ENV MANTIS_FILE mantisbt.tar.gz 

RUN mkdir -p /var/lib/mantisbt && cd /var/lib/mantisbt \
	&& curl -fSL ${MANTIS_URL} -o ${MANTIS_FILE} \
	&& echo "${MANTIS_MD5}  ${MANTIS_FILE}" | md5sum -c \
	&& tar -xz --strip-components=1 -f ${MANTIS_FILE} \
	&& rm ${MANTIS_FILE} \
	&& chown -R www-data:www-data .

ADD ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

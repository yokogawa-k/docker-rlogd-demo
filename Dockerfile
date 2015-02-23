FROM buildpack-deps:jessie
MAINTAINER Kazuya Yokogawa "yokogawa-k@klab.com"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    libev-dev \
    libpcre3-dev \
    apache2-bin \
    apache2.2-common \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

RUN echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure tzdata

# setup apache2
RUN mkdir -vp /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html \
    && echo 'rlogd test!!' >/var/www/html/index.html \
    && chown -vR www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

RUN a2dismod mpm_event && a2enmod mpm_prefork
RUN mv -v /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist
COPY apache2.conf /etc/apache2/apache2.conf

# setup rlogd
RUN git clone https://github.com/pandax381/rlogd.git \
    && cd rlogd \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# setup rlogd/rloggerd
RUN mkdir -vp /var/run/rlogd/buf /var/run/rlogd/rloggerd.buf/ /sockets
COPY ./rlogd.conf /etc/rlogd.conf

CMD rlogd -dF


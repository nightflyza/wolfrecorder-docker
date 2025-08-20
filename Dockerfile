FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y lsb-release apt-transport-https ca-certificates curl gnupg2 && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && apt update

RUN apt install -y wget gnupg2 software-properties-common dirmngr mariadb-server mariadb-client libmariadb-dev default-libmysqlclient-dev apache2 libapache2-mod-php8.4 php8.4-cli php8.4-mysql php8.4-mysqli php8.4-mbstring php8.4-bcmath php8.4-curl php8.4-gd php8.4-snmp php8.4-soap php8.4-zip php8.4-imap php8.4-tokenizer php8.4-xml php8.4-xmlreader php8.4-xmlwriter php8.4-simplexml php8.4-sqlite3 php8.4-sockets php8.4-opcache php8.4-pdo php8.4-pdo-sqlite php8.4-phar php8.4-posix php8.4-memcached php8.4-redis memcached redis ffmpeg sudo vim-tiny elinks expect net-tools netdiag htop rsyslog cron supervisor dialog iputils-ping inetutils-traceroute dnsutils

RUN apt clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod headers expires

RUN mkdir -p /var/www/html/wr /usr/local/wrinstaller /wrstorage && chmod -R 777 /wrstorage /var/www/html/wr

WORKDIR /usr/local/wrinstaller
RUN wget http://wolfrecorder.com/wr.tgz && tar zxvf wr.tgz -C /var/www/html/wr && chmod -R 777 /var/www/html/wr/content /var/www/html/wr/config /var/www/html/wr/exports /var/www/html/wr/howl

RUN cp -R /var/www/html/wr/dist/presets/debian/apache2.conf /etc/apache2/apache2.conf && cp -R /var/www/html/wr/dist/presets/debian/php8.ini /etc/php/8.4/apache2/php.ini && cp -R /var/www/html/wr/dist/presets/debian/000-default.conf /etc/apache2/sites-enabled/000-default.conf && cp -R /var/www/html/wr/dist/landing/index.html /var/www/html/index.html && cp -R /var/www/html/wr/dist/landing/bg.gif /var/www/html/

RUN mkdir -p /data/bin && \
    cp /var/www/html/wr/dist/wrap/deb_wrapi /data/bin/wrapi && \
    cp /var/www/html/wr/dist/presets/debian/autowrupdate.sh /data/bin/autowrupdate.sh && \
    chmod +x /data/bin/*

RUN ln -s /data/bin/wrapi /bin/wrapi && \
    ln -s /data/bin/autowrupdate.sh /bin/autowrupdate.sh

RUN echo "User_Alias WOLFRECORDER = www-data" > /etc/sudoers.d/wolfrecorder && \
    echo "WOLFRECORDER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wolfrecorder && \
    chmod 440 /etc/sudoers.d/wolfrecorder    

COPY crontab.preconf /etc/cron.wr
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf

RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]

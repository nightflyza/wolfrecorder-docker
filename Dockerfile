FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y lsb-release apt-transport-https ca-certificates curl gnupg2 && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && apt update

RUN apt install -y wget gnupg2 software-properties-common dirmngr mariadb-server mariadb-client libmariadb-dev default-libmysqlclient-dev apache2 libapache2-mod-php8.3 php8.3-cli php8.3-mysql php8.3-mysqli php8.3-mbstring php8.3-bcmath php8.3-curl php8.3-gd php8.3-snmp php8.3-soap php8.3-zip php8.3-imap php8.3-tokenizer php8.3-xml php8.3-xmlreader php8.3-xmlwriter php8.3-simplexml php8.3-sqlite3 php8.3-sockets php8.3-opcache php8.3-pdo php8.3-pdo-sqlite php8.3-phar php8.3-posix php8.3-memcached php8.3-redis memcached redis ffmpeg sudo vim-tiny elinks expect net-tools netdiag htop rsyslog cron supervisor dialog iputils-ping inetutils-traceroute dnsutils

RUN apt clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod headers expires

RUN mkdir -p /var/www/html/wr /usr/local/wrinstaller /wrstorage && chmod -R 777 /wrstorage /var/www/html/wr

WORKDIR /usr/local/wrinstaller
RUN wget http://wolfrecorder.com/wr.tgz && tar zxvf wr.tgz -C /var/www/html/wr && chmod -R 777 /var/www/html/wr/content /var/www/html/wr/config /var/www/html/wr/exports /var/www/html/wr/howl

RUN cp -R /var/www/html/wr/dist/presets/debian121/debi12_apache2.conf /etc/apache2/apache2.conf && cp -R /var/www/html/wr/dist/presets/debian121/php82.ini /etc/php/8.3/apache2/php.ini && cp -R /var/www/html/wr/dist/presets/debian121/000-default.conf /etc/apache2/sites-enabled/000-default.conf && cp -R /var/www/html/wr/dist/landing/index.html /var/www/html/index.html && cp -R /var/www/html/wr/dist/landing/bg.gif /var/www/html/


RUN mkdir -p /data/bin && \
    cp /var/www/html/wr/dist/wrap/deb121_wrapi /data/bin/wrapi && \
    cp /var/www/html/wr/dist/presets/debian121/autowrupdate.sh /data/bin/autowrupdate.sh && \
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

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y lsb-release apt-transport-https ca-certificates curl gnupg2 &&     curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg &&     echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list &&     apt update

RUN apt install -y wget gnupg2 software-properties-common dirmngr mariadb-server mariadb-client libmariadb-dev default-libmysqlclient-dev apache2 libapache2-mod-php8.2 php8.2-cli php8.2-mysql php8.2-mysqli php8.2-mbstring     php8.2-bcmath php8.2-curl php8.2-gd php8.2-snmp php8.2-soap php8.2-zip php8.2-imap php8.2-tokenizer php8.2-xml php8.2-xmlreader php8.2-xmlwriter php8.2-simplexml php8.2-sqlite3 php8.2-sockets php8.2-opcache php8.2-pdo php8.2-pdo-sqlite php8.2-phar php8.2-posix php8.2-memcached php8.2-redis memcached redis ffmpeg graphviz sudo ipset vim-tiny elinks mc nano nmap mtr expect git net-tools netdiag htop rsyslog perl cron supervisor dialog iputils-ping inetutils-traceroute dnsutils

RUN a2enmod headers expires

RUN mkdir -p /var/www/html/wr /usr/local/wrinstaller /wrstorage && chmod -R 777 /wrstorage /var/www/html/wr

WORKDIR /usr/local/wrinstaller
RUN wget http://wolfrecorder.com/wr.tgz &&     tar zxvf wr.tgz -C /var/www/html/wr &&     chmod -R 777 /var/www/html/wr/content /var/www/html/wr/config /var/www/html/wr/exports /var/www/html/wr/howl

RUN cp -R /var/www/html/wr/dist/presets/debian121/debi12_apache2.conf /etc/apache2/apache2.conf &&     cp -R /var/www/html/wr/dist/presets/debian121/php82.ini /etc/php/8.2/apache2/php.ini &&     cp -R /var/www/html/wr/dist/presets/debian121/000-default.conf /etc/apache2/sites-enabled/000-default.conf &&     cp -R /var/www/html/wr/dist/landing/index.html /var/www/html/index.html &&     cp -R /var/www/html/wr/dist/landing/bg.gif /var/www/html/


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

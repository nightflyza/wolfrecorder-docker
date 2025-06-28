#!/bin/bash
set -e

mysqld_safe &
sleep 3
until mysqladmin ping &>/dev/null; do sleep 1; done

# Створюємо користувача тільки, якщо БД ще нема
DB_EXISTS=$(mysql -u root -sse "SHOW DATABASES LIKE 'wr'")
if [ "$DB_EXISTS" != "wr" ]; then
    mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'mylogin'@'localhost' IDENTIFIED BY 'newpassword';
GRANT ALL PRIVILEGES ON *.* TO 'mylogin'@'localhost';
FLUSH PRIVILEGES;
EOF

    mysql -u root < /var/www/html/wr/dist/dumps/wolfrecorder.sql
    mysql -u root --database=wr < /var/www/html/wr/dist/dumps/defaultstorage.sql
fi

#MYSQL_INI="/var/www/html/wr/config/mysql.ini"
#if [ -f "$MYSQL_INI" ]; then
#    sed -i 's/^username = .*/username = "mylogin"/' "$MYSQL_INI"
#    sed -i 's/^password = .*/password = "newpassword"/' "$MYSQL_INI"
#fi

BINPATHS_FILE="/var/www/html/wr/config/binpaths.ini"

echo "SUDO=$(which sudo)" > "$BINPATHS_FILE"
echo "CAT=$(which cat)" >> "$BINPATHS_FILE"
echo "GREP=$(which grep)" >> "$BINPATHS_FILE"
echo "UPTIME=$(which uptime)" >> "$BINPATHS_FILE"
echo "PING=$(which ping)" >> "$BINPATHS_FILE"
echo "TAIL=$(which tail)" >> "$BINPATHS_FILE"
echo "KILL=$(which kill)" >> "$BINPATHS_FILE"
echo "PS=$(which ps)" >> "$BINPATHS_FILE"
echo "CD=$(which pwd)" >> "$BINPATHS_FILE"
echo "MYSQLDUMP_PATH=$(which mysqldump)" >> "$BINPATHS_FILE"
echo "MYSQL_PATH=$(which mysql)" >> "$BINPATHS_FILE"
echo "FFMPG_PATH=$(which ffmpeg)" >> "$BINPATHS_FILE"
echo "REBOOT=$(which reboot)" >> "$BINPATHS_FILE"

service apache2 start
sleep 3

curl -s -o /dev/null "http://127.0.0.1/wr/?module=remoteapi&action=identify&param=save"
sleep 5

WR_SERIAL_FILE="/var/www/html/wr/exports/wrserial"
if [ -f "$WR_SERIAL_FILE" ]; then
    NEW_WRSERIAL=$(cat "$WR_SERIAL_FILE" | tr -d '\r\n')
    echo "WR serial read: [$NEW_WRSERIAL]"

    if [ -n "$NEW_WRSERIAL" ]; then
      sed -i "s/WR00000000000000000000000000000000/${NEW_WRSERIAL}/g" /bin/wrapi
      echo "WR serial patched into /bin/wrapi"
    else
        echo "WR serial file is empty!"
    fi
else
    echo "WR serial file not found!"
fi

service apache2 stop
sleep 2

crontab -u www-data /etc/cron.wr

exec /usr/bin/supervisord -c /etc/supervisord.conf

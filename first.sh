#! /bin/bash
yum update
yum install nginx
systemctl start nginx
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum --disablerepo="*" --enablerepo="remi-safe" list php[7-9][0-9].x86_64
sudo yum-config-manager --enable remi-php74
sudo yum install php php-mysqlnd php-fpm
php --version
cat >/etc/php-fpm.d/www.conf <<"EOF"
; Start a new pool named 'www'.
[www]


listen = /var/run/php-fpm/php-fpm.sock;
listen.allowed_clients = 127.0.0.1

listen.owner = nginx
listen.group = nginx
listen.mode = 0666
user = nginx
group = nginx
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
slowlog = /var/log/php-fpm/www-slow.log
php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path] = /var/lib/php/session
EOF
sudo systemctl start php-fpm
cat >/etc/nginx/conf.d/default.conf <<"EOF"
server {
    listen       80;
    server_name  server_domain_or_IP;

    root   /usr/share/nginx/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
systemctl restart nginx
sudo chown -R nginx.nginx /usr/share/nginx/html/
cat >/usr/share/nginx/html/info.php <<"EOF"
    echo "<?php phpinfo(); ?>" >/usr/share/nginx/html/info.php
EOF

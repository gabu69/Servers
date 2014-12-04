server {
 server_name ejemplo.com www.ejemplo.com;
 listen 80;
 root /var/www/ejemplo.com/public_html;
 access_log /var/www/ejemplo.com/logs/access.log;
 error_log /var/www/ejemplo.com/logs/error.log;
 index index.html index.php;

include hhvm.conf;

location / {
    try_files $uri $uri/ /index.php?q=$uri&$args;
    }

location ~ /\.ht {
    deny all;
    }

location ~ \.php$ {
    fastcgi_index index.php;
    fastcgi_keep_conn on;
    include /etc/nginx/fastcgi_params;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

# Ubuntu 16.04

## 1. Actualizamos el servidor

```
sudo apt update
sudo apt upgrade
```

## 2. Instalamos Nginx
1. Instalar
````
sudo apt-get install software-properties-common python-software-properties
sudo add-apt-repository ppa:nginx/stable
sudo apt-get update
sudo apt-get install nginx
sudo /etc/init.d/nginx restart
sudo nginx -t
````
2. Configurar Nginx 
`sudo nano /etc/nginx/nginx.conf`
````
user www-data;
worker_processes 6;
pid /run/nginx.pid;

events {
        worker_connections 6000;

    # optmized to serve many clients with each thread, essential for linux
    use epoll;
    # accept as many connections as possible, may flood worker connections if set too low
    multi_accept on;
}

http {

        ### Basic Settings ##
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

 ### File max size 20mb ###
 client_max_body_size 30m;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # Logging Settings
        ##
        access_log off;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##
        gzip on;
        gzip_disable "msie6";
        gzip_comp_level 2;
        gzip_min_length 1000;
        gzip_proxied expired no-cache no-store private auth;
        gzip_types text/plain application/x-javascript text/xml text/css application/xml;

        ##
        # Virtual Host Configs
        ##
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;


fastcgi_buffers 8 16k;
fastcgi_buffer_size 32k;
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;

### Filehandle cache
open_file_cache          max=10000 inactive=20s;
open_file_cache_valid    60s;
open_file_cache_min_uses 3;
open_file_cache_errors   on;

}

````
## 3. MySQL - MariaDB
1. Descargamos de [MariaDB Foundation](https://downloads.mariadb.org/mariadb/repositories/#mirror=digitalocean-sfo)
2. Corremos `mysql_secure_installation`

## 4. HHVM
1. [Descargar HHVM](https://docs.hhvm.com/hhvm/installation/linux)

```
sudo /usr/share/hhvm/install_fastcgi.sh
sudo /etc/init.d/hhvm restart
sudo /etc/init.d/nginx restart
sudo ln -s $(which hhvm) /usr/local/bin/php
sudo update-rc.d hhvm defaults
```
## 5. Configuramos Nginx para el servidor
1. Configuramos la carpeta y el archivo del servidor
```
cd /etc/nginx/sites-available/
rm -rf *
sudo nano /etc/nginx/sites-available/sitio.com
```
2. Agregamso el codigo acorde

```
server {
 server_name IP;
 listen  80;
 root /var/www/SITIO.com/public_html;
 access_log off;
 error_log /var/www/SITIO.com/logs/error.log;
 index index.html index.htm index.php;

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

##### Enabling HTTP Strict Transport Security on Your Server
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
}
```
3. Y creamos un enlace desde el directorio /etc/nginx/sites-enabled para que Nginx sepa que ese nuevo sitio web estará habilitado: 

`sudo ln -s /etc/nginx/sites-available/SITIO.com /etc/nginx/sites-enabled/SITIO.com`

## 6. WordPress en public_html:

1. Ahora deberemos crear los directorios que le hemos indicado en ese fichero de configuración que usaremos como destinos para los registros de acceso y errores y, por supuesto, como raíz de nuestro sitio web:

```
sudo mkdir -p /var/www/SITIO.com/{logs,public_html}
sudo chown -R www-data:www-data /var/www/
```
2. Y ahora instalamos WordPress en public_html:
```
cd /var/www/SITIO.com/public_html
sudo wget http://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress
sudo rm latest.tar.gz
```
3. Es el momento de crear la base de datos para nuestro blog. Para ello, entramos en el gestor de base de datos con el siguiente comando (se nos pedirá la contraseña del administrador de la base de datos):

`mysql -uroot -p`
4. Tras lo cual podremos crear la base de datos y dejarla preparada con los siguientes comandos. Atención a dos cosas: 
   - El uso de mayúsculas es opcional, pero no os olvidéis de los puntos y coma salvo en el exit final, y 
   - Elegid de nuevo una contraseña específica para esa base de datos que solo afectará a ese blog en particular.
```
CREATE DATABASE WP_blog;
GRANT ALL PRIVILEGES ON WP_blog.* TO wp_blog@localhost IDENTIFIED BY 'unacontrasena';
FLUSH PRIVILEGES;
exit
```

5. Con esto ya tendremos esa parte preparada, y ahora falta indicarle a WordPress que esa es precisamente la base de datos que queremos utilizar. Para ello, creamos el fichero wp-config.php en el que se encuentran esos datos:
```
mv wp-config-sample.php wp-config.php
nano wp-config.php
```
6. Y como se ve en la imagen, añadimos en ese fichero los datos de la base de datos que acabamos de crear. Ahora nos aseguramos de que el directorio raíz tiene los propietarios adecuados, y reiniciamos nginx:
```
cd /var/www/SITIO.com
sudo chown -R www-data:www-data public_html/
sudo service nginx restart
```
7. y ya podremos acceder a la instalación de WordPress, primero para completarla, haciendo que nuestro navegador vaya a

http://SITIO.com/

8. Si esa URL no funciona, probad con ‘http://lastresjotas.com/wp-admin/install.php‘ Tras lo cual se nos pedirá el nombre del blog, el nombre del administrador, una contraseña y una dirección de correo electrónico.

9. Corremots algunos ultimos detalles
```
sudo chown -R www-data:www-data /var/www/
sudo chown -R www-data:www-data /var/www/SITIO.compublic_html/
chown -R www-data:www-data /var/www/SITIO.com/
```
## 7. Varnish

### Instalamos y configuramos Varnish
```
sudo apt-get install varnish
sudo nano /etc/default/varnish
```
```
# Configuration file for varnish
#
# /etc/init.d/varnish expects the variables $DAEMON_OPTS, $NFILES and $MEMLOCK
# to be set from this shell script fragment.
#
# Note: If systemd is installed, this file is obsolete and ignored.  You will
# need to copy /lib/systemd/system/varnish.service to /etc/systemd/system/ and
# edit that file.

# Should we start varnishd at boot?  Set to "no" to disable.
START=yes

# Maximum number of open files (for ulimit -n)
NFILES=131072

# Maximum locked memory size (for ulimit -l)
# Used for locking the shared memory log in memory.  If you increase log size,
# you need to increase this number as well
MEMLOCK=82000

DAEMON_OPTS="-a :80 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish/secret \
             -s malloc,10G"
```

`sudo nano /etc/varnish/default.vcl`

Agregamos alguna de estas versiones del [default.vcl](https://github.com/gabu69/Servers/tree/master/Varnish)

### Cambiamos Nginx
`sudo nano /etc/nginx/sites-available/sitio.com`

Cambiamos a:

` listen  127.0.0.1:8080; ## listen for ipv4; this line is default and implied`

Borramos: 

`sudo rm /etc/nginx/sites-enabled/default`

Reiniciamos todo:

```
sudo service nginx restart
sudo service varnish restart
```

## 8. Fail2ban
```
sudo apt-get install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```




























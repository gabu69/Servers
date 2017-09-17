# Ubuntu 16.04
  
* https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04   
* https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lemp-on-ubuntu-16-04   
  
## 1. Actualizamos el servidor

```
apt-get update && apt-get upgrade
```

## 2. Instalamos Nginx
1. `sudo apt-get install nginx`
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
3. Corremos
````
sudo systemctl reload nginx
````
4. Actualizamos Nginx a la ultima version (se tiene que actualizar espues del setup anterior sino tendremos problemas): https://www.linuxbabe.com/nginx/nginx-latest-version-ubuntu-16-04-16-10

## 3. MySQL - MariaDB
1. Descargamos de [MariaDB Foundation](https://downloads.mariadb.org/mariadb/repositories/#mirror=rafal&distro=Ubuntu&distro_release=xenial--ubuntu_xenial&version=10.2)
2. Corremos `mysql_secure_installation`

## 4. PHP7
1. Instalamos PHP7 con todas sus dependencias [Configuramos PHP7](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04#step-3-install-php-for-processing)

```
sudo apt-get install php-fpm php-mysql php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc php7.0-xml
```
Tenemos que asegurar la instalacion
```
sudo nano /etc/php/7.0/fpm/php.ini
```
Buscamos **;cgi.fix_pathinfo=1**, descomentamos y dejamos como:
```
cgi.fix_pathinfo=0
```
Salvamos y reiniciamos PHP
```
sudo systemctl restart php7.0-fpm
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
        listen 80 default_server;
        server_name 66.228.48.246;

        root /var/www/SITIO.com/public_html;

        error_log /var/www/SITIO.com/logs/error.log;
        access_log off;

        # Add index.php to the list if you are using PHP
        index index.php index.html index.htm index.nginx-debian.html;

        location / {
                try_files $uri $uri/ /index.php?q=$uri&$args;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
         location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        location ~ /\.ht {
                deny all;
        }

        #### Enabling HTTP Strict Transport Security on Your Server
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";


}
```
3. Y creamos un enlace desde el directorio /etc/nginx/sites-enabled para que Nginx sepa que ese nuevo sitio web estará habilitado: 

`sudo ln -s /etc/nginx/sites-available/SITIO.com /etc/nginx/sites-enabled/SITIO.com`
## 6. Revisamos Este bien todo
Usando de ejemplo https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04#step-5-create-a-php-file-to-test-configuration:
```
nano /var/www/SITIO.com/public_html/info.php
```
Metemos este codigo
```
<?php
phpinfo();
```
Revisamos en **http://IP_DEL_SERVIDO/Rinfo.php** y si corre todo, todo esta bien y luego borramos la info del PHP
```
sudo rm /var/www/SITIO.com/public_html/info.php
```

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

Asimismo, agregamos al final del **wp-config.php** el server push de Cloudflare:
```
define('WP_DEBUG', false);
define('CLOUDFLARE_HTTP2_SERVER_PUSH_ACTIVE', true);
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
sudo chown -R www-data:www-data /var/www/SITIO.com/public_html/
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

### Nota si no funciona varnish
You might run into some issues with installing Varnish on Ubuntu 16. If you get an error, check the process that’s running on your server.

`ps aux | grep vcache`
```
vcache 15569 0.0 0.7 125044 7816 ? Ss 08:20 0:00 /usr/sbin/varnishd -j unix,user=vcache -F -a :6081 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m
vcache 15581 0.0 9.3 272012 94900 ? Sl 08:20 0:00 /usr/sbin/varnishd -j unix,user=vcache -F -a :6081 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m
```
You may see that the port is still set to 6081 instead the one you set in /etc/default/varnish. What this means is that the systemd service bypassed the configuration file.

In order to solve the problem, edit the file /lib/systemd/system/varnish.service and change the port 6081 to 80. Also, you can change the malloc,256 for a different memory value at this time.

`nano /lib/systemd/system/varnish.service`
```
[...]
ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :6081 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m
[...]
```
to
```
[...]
ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m
[...]
```
Reload and restart Nginx and Varnish once more.
```
systemctl daemon-reload
systemctl restart nginx.service
systemctl restart varnish.service
```
Check your Varnish stats to make sure everything’s working correctly.

`varnishstat`

Finally, ensure that your web server and Varnish are operating normally.

`curl -I http://your_ip`

```
HTTP/1.1 200 OK
Date: Wed, 22 Jun 2016 08:32:03 GMT
Server: Apache/2.4.18 (Ubuntu)
Last-Modified: Wed, 22 Jun 2016 08:18:20 GMT
Vary: Accept-Encoding
Content-Type: text/html
X-Varnish: 32771
Age: 0
Via: 1.1 varnish-v4
ETag: W/"2c39-535d9949460b3-gzip"
Accept-Ranges: bytes
Connection: keep-alive
```
With Varnish installed, you can rest easy that your site will survive an unexpected surge of visitors and be better protected against any malicious attacks. If this guide was helpful to you, kindly share it with others who may also be interested.

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

#UBUNTU 14.04
Update repository and upgrade  
`apt-get update && apt-get upgrade`  
##Mariadb Intall  
  1.  https://downloads.mariadb.org/mariadb/repositories/#mirror=digitalocean-nyc  
  2.  `mysql_secure_installation`  

Hacer usuario, base de datos, password de la base de datos  
 1. `mysql -uroot -p`  
 2. `CREATE DATABASE basededatos;`  
 3. `GRANT ALL PRIVILEGES ON basededatos.* TO usuariomysql@localhost IDENTIFIED BY 'unacontrasena';`  
 4. `FLUSH PRIVILEGES;`  
 5. `exit`  

##Nginx (install latest):  
`sudo apt-get install python-software-properties`  
`sudo add-apt-repository ppa:nginx/stable`  
`sudo apt-get update`  
`sudo apt-get install nginx`  
`sudo /etc/init.d/nginx restart`  
`sudo nginx -t`  
##HHVM (install)
`wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -`  
`echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list`  
`sudo apt-get update`  
`sudo apt-get install hhvm`  
###After   
 `sudo /usr/share/hhvm/install_fastcgi.sh`  
`sudo /etc/init.d/hhvm restart`  
`sudo /etc/init.d/nginx restart`
###Link NGINX and HHVM  
`ln -s $(which hhvm) /usr/local/bin/php`  
**Wasn't included in the guide but seems to be needed**  
Run on boot:  
 * `sudo update-rc.d hhvm defaults` <-Checar esta configuracion   
 * 


## Configurar Sitio
 1. `sudo nano /etc/nginx/sites-available/nombre.com`  <-- checar configuracion la tengo aqui en github
 2.  `sudo ln -s /etc/nginx/sites-available/nombre.com /etc/nginx/sites-enabled/nombre.com`  
 3.  `sudo mkdir -p /var/www/ejemplo.com/{logs,public_html}`  
 4.  `sudo chown -R www-data:www-data /var/www/`  
 5.  `cd /var/www/ejemplo.com`  
 6.  `sudo chown -R www-data:www-data public_html/`  
 7.  `sudo service nginx restart`  

Se necesita tener un archivo index.html/index/index.php para que de permiso de ver ojo con eso
##Recommendations:
###NGINX
 * Optimize NGINX: https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration  

## Install Varnish  
https://www.varnish-cache.org/installation/ubuntu

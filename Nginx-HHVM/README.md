#UBUNTU 14.04
Update repository and upgrade  
`apt-get update && apt-get upgrade`  
##Mariadb Intall  
  1.  https://downloads.mariadb.org/  
  2.  `mysql_secure_installation`  

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
 1. `sudo nano /etc/nginx/sites-available/nombre.com`  
 2.  

##Recommendations:
###NGINX
 * Optimize NGINX: https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration  

## Install Varnish  
https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-14-04-lts

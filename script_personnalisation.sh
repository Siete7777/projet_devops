#/bin/bash

docker exec -it projet_devops apt install unzip
docker exec -it owncloud cd /var/www/owncloud/apps
docker exec -it owncloud wget https://github.com/owncloud/theme-example/archive/master.zip
docker exec -it owncloud unzip master.zip
docker exec -it owncloud rm master.zip
docker exec -it owncloud mv theme-example-master mynewtheme
docker exec -it owncloud sed -i "s#<id>theme-example<#<id>mynewtheme<#" "mynewtheme/appinfo/info.xml"
docker exec -it owncloud sudo chown -R www-data: mynewtheme
docker exec -it owncloud sudo -u www-data ./occ app:enable mynewtheme

docker exec -it owncloud sudo cd /var/www/owncloud/core/img | mv background.jpg old_background.jpg | wget -O background.jpg https://www.eliott-markus.com/wp-content/uploads/2023/08/Groupe-1931@2x-min.png.webp

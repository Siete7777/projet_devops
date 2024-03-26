#!/bin/bash

# Installer unzip dans le conteneur projet_devops
docker exec -it projet_devops apt-get update && apt install -y unzip

# Télécharger et installer le thème personnalisé
docker exec -it owncloud bash -c ' \
    cd /var/www/owncloud/apps && \
    wget https://github.com/owncloud/theme-example/archive/master.zip && \
    unzip master.zip && \
    rm master.zip && \
    mv theme-example-master mynewtheme && \
    sed -i "s#<id>theme-example<#<id>mynewtheme<#" "mynewtheme/appinfo/info.xml" && \
    chown -R www-data:www-data mynewtheme && \
    sudo -u www-data php occ app:enable mynewtheme \
'

# Mettre à jour l'image de fond
docker exec -it owncloud bash -c ' \
    cd /var/www/owncloud/core/img && \
    mv background.jpg old_background.jpg && \
    wget -O background.jpg https://www.eliott-markus.com/wp-content/uploads/2023/08/Groupe-1931@2x-min.png.webp \
'

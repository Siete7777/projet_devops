FROM owncloud/server:latest

# Copier le script shell dans le conteneur
COPY setup_owncloud.sh /usr/local/bin/

# Exécuter le script shell
RUN chmod +x /usr/local/bin/setup_owncloud.sh && \
    /usr/local/bin/setup_owncloud.sh

# Optionnel : Nettoyer le conteneur
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



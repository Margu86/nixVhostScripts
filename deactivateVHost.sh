# dectivate VirtualHost

read -p "PLeas enter the domainname to be shut down (Bsp.: wardragon.de): " entereddomain
echo "Domain $entereddomain was entered"
export DOMAIN=$entereddomain

# deactivate Apache configuration
sudo a2dissite $DOMAIN.conf
sudo service apache2 restart

# deactivate NginX configuration
sudo rm /etc/nginx/sites-enabled/$DOMAIN
sudo service nginx restart

# re-activate VirtualHost

read -p "Please enter the domain to be re-activated (Bsp.: wardragon.de): " entereddomain
echo "Domain $entereddomain was entered"
export DOMAIN=$entereddomain

# re-activate Apache configuration
sudo a2ensite $DOMAIN.conf
sudo service apache2 restart

# re-activate NginX configuration
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo service nginx restart

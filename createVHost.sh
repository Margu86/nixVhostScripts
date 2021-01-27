# Create VirtualHost for a domain (if not allready done)
# switch eure-url.de to your actual URL.

read -p "PLease enter the Domainname of the new domain (Example.: wardragon.de): " entereddomain
echo "Domain $entereddomain was entered"

# with export DOMAIN we set a environment variable wich we can later use as $DOMAIN
export DOMAIN=$entereddomain

# Step 1 - Create Directory ans set rights
sudo mkdir /var/www/vhosts/$DOMAIN
sudo mkdir /var/www/vhosts/$DOMAIN/log
sudo mkdir /var/www/vhosts/$DOMAIN/log/apache2
sudo mkdir /var/www/vhosts/$DOMAIN/htdocs
sudo chown -R www-data.www-data /var/www/vhosts/$DOMAIN

# Step 2 - Create Apache config for domain.de
printf "
<VirtualHost *:8080>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot /var/www/vhosts/$DOMAIN/htdocs
    ErrorLog /var/www/vhosts/$DOMAIN/log/apache2/error.log
    CustomLog /var/www/vhosts/$DOMAIN/log/apache2/access.log combined
</VirtualHost>

<Directory /var/www/vhosts/$DOMAIN/htdocs/>
    AllowOverride All
</Directory>" | sudo tee /etc/apache2/sites-available/$DOMAIN.conf


# Step 3 - activate VirtualHost configuration for our domain
sudo a2ensite $DOMAIN.conf
sudo ervice pache2 restart

# Step 4 - create NginX configuration
printf "
server {
        server_name $DOMAIN www.$DOMAIN;
        return 301 https://\$host\$request_uri;
}

server {
        root /var/www/vhosts/$DOMAIN/htdocs;
        index index.html index.htm index.php index.nginx-debian.html;
        server_name $DOMAIN www.$DOMAIN;
        location / {
                proxy_pass http://127.0.0.1:8080;
                include /etc/nginx/proxy_params;
        }
        location ~*\\\.(js|css|jpg|jpeg|gif|png|svg|ico|pdf|html|htm)\$ {
                expires 15d;
        }
        location @proxy {
                proxy_pass http://127.0.0.1:8080;
                include /etc/nginx/proxy_params;
        }
        location ~*\\\.php\$ {
                proxy_pass http://127.0.0.1:8080;
                include /etc/nginx/proxy_params;
        }
}
" | sudo tee /etc/nginx/sites-available/$DOMAIN

# Step 5 - activate NginX configuration

ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo service nginx restart

# Step 6 - generate placeholder html

printf "
<html>
<h1>Willkommen</h1>
<p>Diese Seite befindet sich derzeit im Aufbau oder wird gerade auf einen neuen Server umgezogen.<br/>Haben Sie daher bitte noch ein wenig Gedult und versuchen es sp&auml;ter noch einmal.<br/><br/><b>Vielen Dank f&uuml;r Ihr Verst&auml;ndniss!</b></p>
</html>" | sudo tee /var/www/vhosts/$DOMAIN/htdocs/index.html

# Step 7 - create Letsencryp certificate and add it to our NginX configuration

sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN -w /var/www/vhosts/$DOMAIN/htdocs

# Step8 8 - recreate NginX configuration including the new certificate and restart NginX
printf "server {
        server_name $DOMAIN www.$DOMAIN;
        return 301 https://\$host\$request_uri;
}

server {
        listen 443;
        listen [::]:443;

        root /var/www/vhosts/$DOMAIN/htdocs;
        index index.html index.htm index.php index.nginx-debian.html;
        server_name $DOMAIN www.$DOMAIN;
        location / {
                proxy_pass http://127.0.0.1:8080;
                include /etc/nginx/proxy_params;
        }
        location ~*\\\.(js|css|jpg|jpeg|gif|png|svg|ico|pdf|html|htm)\$ {
                expires 15d;
        }
        location @proxy {
                proxy_pass http://127.0.0.1:8080;
                include /etc/nginx/proxy_params;
        }
        location ~*\\\.php\$ {
                proxy_pass http://127.0.0.1:8080;
                include /etc/nginx/proxy_params;
        }

        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
" | sudo tee /etc/nginx/sites-available/$DOMAIN

sudo service nginx restart

# Step 9 create script to set file permissions

printf "# !/bin/bash

chown -R www-data.www-data htdocs
find htdocs/ -type d -exec chmod 755 {} \;
find htdocs/ -type f -exec chmod 644 {} \;" | sudo tee /var/www/vhosts/$DOMAIN/setPermissions.sh

sudo chmod +x /var/www/vhosts/$DOMAIN/setPermissions.sh
sudo service apache2 restart
clear

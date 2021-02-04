# !/bin/bash

chown -R www-data.www-data htdocs
find htdocs/ -type d -exec chmod 755 {} \;
find htdocs/ -type f -exec chmod 644 {} \;

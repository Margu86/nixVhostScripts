#! /bin/sh

# first cert to be renewed
sudo openssl req -new -sha256 -key sub.dom.tld.key -out sub.dom.tld.csr -subj "/C=DE/ST=State-Region/L=Location/O=Organization/OU=OrgUnit/CN=sub.dom.tld"
cat sub.dom.tld.csr

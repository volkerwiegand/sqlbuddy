## sqlbuddy

This repository contains the Dockerfile to build an image for SQL Buddy
http://sqlbuddy.com/

The image uses PHP 5.6 and is based upon the official docker PHP image
https://hub.docker.com/_/php/

### Features

* Works over HTTP or HTTPS (using the host certificate)

* Does not require URL rewriting when called via sub-uri

### Example

    docker run -e SERVER_NAME=www.example.com -e SERVER_ADMIN=webmaster@example.com SQLBUDDY_URI=/admin/sqlbuddy -p 127.0.0.1:7443:443 -v /etc/pki/tls:/etc/apache2/tls:ro -e CERT_NAME=StartCom volkerwiegand/sqlbuddy:1.3.3

This would expect a PEM certificate at /etc/pki/tls/certs/StartCom.pem
(starting with the server certificate, followed by the certificate chain
up to the root), and the corresponding private key
at /etc/pki/tls/private/StartCom.key.

The Apache's server and admin name will be set correctly. Also, the URIs
coming out of SQL Buddy will already be formed correctly.

### Environment variables

*SERVER_NAME*

  Usually the name of the host running SQL Buddy. Used for setting up Apache.

*SERVER_ADMIN*

  Also used for setting up Apache.

*SQLBUDDY_URI*

  This helps to call SQL Buddy as e.g. https://www.example.com/admin/sqlbuddy/
  See below for an Nginx configuration example.

*CERT_NAME*

  If this variable is set and if /etc/apache2/tls is a directory (usually
  included via bind mount) then SQL Buddy can use the host's
  SSL certificate and key. See above for the naming conventions and file
  locations. The layout is modelled after CentOS and other Enterprise Linux
  variants.

### Nginx example

The following code snippet shows an Nginx location block to reverse proxy
calls entered as https://www.example.com/admin/sqlbuddy/ to the docker container as
installed using the command line above.

    location ~ ^(/admin/sqlbuddy)(.*)$ {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_pass https://127.0.0.1:7443$1$2;
    }
 

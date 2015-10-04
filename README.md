## sqlbuddy

This repository contains the Dockerfile to build an image for SQL Buddy
http://sqlbuddy.com/

The image uses PHP 5.6 and is based upon the official docker PHP image
https://hub.docker.com/_/php/

### Features

* Does not require URL rewriting when called via sub-uri

### Example

    docker run -e SERVER_NAME=www.example.com -e SERVER_ADMIN=webmaster@example.com SQLBUDDY_URI=/admin/sqlbuddy -e LOG_LEVEL=debug -p 127.0.0.1:8010:80 volkerwiegand/sqlbuddy:1.3.3

### Environment variables

*SERVER_NAME*

  Usually the name of the host running SQL Buddy. Used for setting up Apache.

*SERVER_ADMIN*

  Also used for setting up Apache.

*SQLBUDDY_URI*

  This helps to call SQL Buddy as e.g. https://www.example.com/admin/sqlbuddy/
  See below for an Nginx configuration example.

*LOG_LEVEL*

  The apache log level (defaults to warn).

### Nginx example

The following code snippet shows an Nginx location block proxying
https://www.example.com/admin/sqlbuddy/ to the docker container
installed using the command line above.

    location /admin/sqlbuddy {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_pass https://127.0.0.1:8010;
    }
 

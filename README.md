## mantisbt

This repository contains the Dockerfile to build an image for MantisBT
http://mantisbt.org/

The image uses PHP 5.6 and is based upon the official docker Apache PHP image
https://hub.docker.com/_/php/

### Features

* Does not require URL rewriting when called via sub-uri

### Example

    docker run -e SERVER_NAME=www.example.com -e SERVER_ADMIN=webmaster@example.com -e MANTISBT_URI=/mantisbt -e LOG_LEVEL=debug -p 127.0.0.1:8010:80 volkerwiegand/mantisbt:1.3.2

### Environment variables

*SERVER_NAME*

  Usually the name of the host running MantisBT. Used for setting up Apache.

*SERVER_ADMIN*

  Also used for setting up Apache.

*MANTISBT_URI*

  This helps to call MantisBT as e.g. https://www.example.com/mantisbt/
  See below for an Nginx configuration example.

*LOG_LEVEL*

  The apache log level (defaults to warn).

### Nginx example

The following code snippet shows an Nginx location block proxying
https://www.example.com/mantisbt/ to the docker container
installed using the command line above.

    location /mantisbt {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_pass http://127.0.0.1:8010;
    }
 
### License

The MIT License (MIT)

Copyright (c) 2016 Volker Wiegand


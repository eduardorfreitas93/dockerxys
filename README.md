# dockerxys v4.0

### Containers

* nginx
* phpfpm:7.1
* postgres:9.5
* docker-sync

### Update

* Versão do php

> Foi retirado do repositório o arquivos do freetds.conf

### Config docker-sync

* docker volume create --name=app-sync
* docker-compose -f docker-compose-dev.yml up -d
* docker-sync start
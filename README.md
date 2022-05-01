
## Requirement
* [docker](https://docs.docker.com/get-docker/)
* [docker-compose](https://docs.docker.com/compose/install/)

## Clone
```shell
> git clone --recurse-submodules -j8 git@github.com:harold93/booklet-loadbalancer.git
```
## Run
```shell
> booklet.sh
```

### To add a node package
```shell
> docker-compose exec nuxt yarn add <package nane>
```

### To add a ruby package
```shell
> docker-compose exec rails bundle add <package nane>
```

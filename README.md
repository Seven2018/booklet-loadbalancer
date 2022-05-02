
## Requirement
sevenup.sh will install them for you
* [docker](https://docs.docker.com/get-docker/)
* [docker-compose](https://docs.docker.com/compose/install/)

## Clone
```shell
> git clone --recurse-submodules -j8 git@github.com:Seven2018/booklet-loadbalancer.git
```
## Run
```shell
> sevenup.sh
```

### To add a node package
```shell
> sevenup.sh -d exec nuxt yarn add <package nane>
```

### To add a ruby package
```shell
> sevenup.sh -d rails bundle add <package nane>
```

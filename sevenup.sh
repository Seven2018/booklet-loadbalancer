#!/usr/bin/env bash

# add colors
source ./colors.sh

print_c() {
  echo -e "$1$2$NO_COLOR"
}

check_requirement() {
  if ! command -v docker &>/dev/null || ! command -v docker-compose &>/dev/null; then
    print_c $Red "Error: docker and docker-compose need to be installed"
    if [[ $OSTYPE == 'darwin'* ]]; then
      exit 1
    fi

    read -p "Do you want to install them ? (y/n) " yn
    case $yn in
    y | yes)
      print_c $Yellow "installing docker..."
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

      print_c $Yellow "installing docker-compose..."
      sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose

      print_c $Yellow "runnig docker without sudo, need a restart..."
      sudo groupadd docker
      sudo usermod -aG docker $USER
      newgrp docker
      ;;
    n | no)
      print_c $Yellow "exiting...come back when it will be installed"
      exit 1
      ;;
    *)
      echo invalid response
      exit 1
      ;;
    esac
    exit 1
  fi
}

check_hosts() {
  grep "127.0.0.1 booklet.localhost" /etc/hosts &>/dev/null
  if [[ $? -eq 1 ]]; then
    print_c $Yellow "Adding host http://booklet.localhost"
    echo -e '\n127.0.0.1 booklet.localhost' | sudo tee -a /etc/hosts &>/dev/null
  fi
}

check_services() {
  sudo service postgresql status
  if [[ $? -eq 0 ]]; then
    sudo service postgresql stop
  fi
  # TODO: test on a machine
  sudo service redis status
  if [[ $? -eq 0 ]]; then
    sudo service redis stop
  fi
}

print_seven() {
  print_c $Purple "\t   /\$\$\$\$\$\$\$  /\$\$\$\$\$\$  /\$\$    /\$\$ /\$\$\$\$\$\$  /\$\$\$\$\$\$\$ "
  print_c $Purple "\t /\$\$_____/ /\$\$__  \$\$|  \$\$  /\$\$//\$\$__  \$\$| \$\$__  \$\$"
  print_c $Purple "\t|  \$\$\$\$\$\$ | \$\$\$\$\$\$\$\$ \  \$\$/\$\$/| \$\$\$\$\$\$\$\$| \$\$  \ \$\$"
  print_c $Purple "\t \____  \$\$| \$\$_____/  \  \$\$\$/ | \$\$_____/| \$\$  | \$\$"
  print_c $Purple "\t /\$\$\$\$\$\$\$/|  \$\$\$\$\$\$\$   \  \$/  |  \$\$\$\$\$\$\$| \$\$  | \$\$"
  print_c $Purple "\t|_______/  \_______/    \_/    \_______/|__/  |__/"
}

start() {
  check_requirement
  check_hosts
  check_services
  print_seven
  #  echo "starting... opt, WITHOUT_LOGS: $1, WITHOUT_RAILS: $2"
  if [[ $2 -eq 1 ]]; then
    sudo lsof -i -P -n | grep LISTEN | grep ':3000'
    if [[ $? -eq 1 ]]; then
      print_c $Red "Error: please run your rails environment before"
      print_c $Yellow "DO NOT FORGET TO RUN RAILS WITH '-b 0.0.0.0' option"
      print_c $Yellow "EXAMPLE: bundle exec rails s -b 0.0.0.0"
      exit 1
    fi
    NGINX_PROXY_RAILS=host.docker.internal docker-compose -f docker-compose.yml -f ./booklet-front/docker-compose.yml -f ./booklet.byseven.co/docker-compose.yml -f ./docker-compose.override-booklet-img.yml up -d db redis webpack sidekiq nuxt loadbalancer
  else
    docker-compose -f docker-compose.yml -f ./booklet-front/docker-compose.yml -f ./booklet.byseven.co/docker-compose.yml -f ./docker-compose.override-booklet-img.yml up -d
  fi

  print_c $Yellow "Booklet ready on: http://booklet.locahost"
  print_c $Yellow "Opening..."
  print_c $Yellow "wait at least 5 minutes then reload"
  if [[ $OSTYPE == 'darwin'* ]]; then
    open http://booklet.localhost
  else
    setsid xdg-open http://booklet.localhost &>/dev/null
  fi
}

alias_docker() {
  local args=("$@")

  shift
  if [[ ${args[0]} -eq 1 ]]; then
    NGINX_PROXY_RAILS=host.docker.internal docker-compose -f docker-compose.yml -f ./booklet-front/docker-compose.yml -f ./booklet.byseven.co/docker-compose.yml -f ./docker-compose.override-booklet-img.yml "$@"
  else
    docker-compose -f docker-compose.yml -f ./booklet-front/docker-compose.yml -f ./booklet.byseven.co/docker-compose.yml -f ./docker-compose.override-booklet-img.yml "$@"
  fi
}

help() {
  echo "$0:"
  echo -e "\t-h | --help:\t\tlist of options"
  echo -e "\t-l | --logs:\t\trun docker with logs"
  echo -e "\t-wr | --without-rails:\trun the project without rails"
  echo -e "\t-d | --docker:\talias for docker project at seven ex: ./sevenup -d exec rails rails c"
}

main() {
  local WITH_LOGS=0
  local WITHOUT_RAILS=0

  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      case $1 in
      -wl | --without-logs)
        echo '---- without logs-----'
        WITH_LOGS=1
        shift # past argument
        ;;
      -wr | --without-rails)
        echo '---- without rails ----'
        WITHOUT_RAILS=1
        shift
        ;;
      -d | --docker)
        shift
        alias_docker $WITHOUT_RAILS "$@"
        exit 0
      ;;
      -h | --help)
        help
        exit 0
        ;;
      -* | --*)
        echo "Error: unknown option $1"
        exit 1
        ;;
      *)
        # unmatched
        echo "Error: unknown argument $1"
        shift # past argument
        ;;
      esac
    done
  fi
  start $WITH_LOGS $WITHOUT_RAILS
}

main "$@"

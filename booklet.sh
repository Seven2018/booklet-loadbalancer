#!/usr/bin/env bash

# add colors
source ./colors.sh

print_c() {
  echo -e "$1$2$NO_COLOR"
}

check_requirement() {
  if ! command -v docker &>/dev/null || ! command -v docker-compose &>/dev/null; then
    print_c $Red "Error: docker and docker-compose need to be installed"
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
  print_seven
  #  echo "starting... opt, WITHOUT_LOGS: $1, WITHOUT_RAILS: $2"
  docker-compose -f docker-compose.yml -f booklet-front/docker-compose.yml up

  print_c $Yellow "Booklet ready on: http://booklet.locahost"
  print_c $Yellow "Opening..."
  if [[ $OSTYPE == 'darwin'* ]]; then
    open http://booklet.localhost
  else
    xdg-open http://booklet.localhost &
    setsid xdg-open http://booklet.localhost &>/dev/null
  fi
}

help() {
  echo "$0:"
  echo -e "\t-h | --help:\t\tlist of options"
  echo -e "\t-l | --logs:\t\trun docker with logs"
  echo -e "\t-wr | --without-rails:\trun the project without rails"
}

main() {
  #  print_c ${Red} "$1"
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

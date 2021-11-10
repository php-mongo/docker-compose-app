#!/bin/bash

PMA_DIR=$(exec 2>/dev/null;cd -- $(dirname "${BASH_SOURCE:-$0}"); unset PWD; /usr/bin/pwd || /bin/pwd || pwd)

pmasetup() {
    BASE_LOC=$(echo "$PMA_DIR" | rev | cut -d'/' -f3- | rev)

    COMPOSE_FILE="./docker/docker-compose.yml"

    COLOR_RED="$(tput setaf 1)"
    COLOR_NONE="$(tput sgr0)"
    COLOR_BLUE="$(tput setaf 6)"

    COMMAND=$1

    # Completely rebuilds fusion - eg. Xdebug change
    # Set arg #1 to 1 to enable xdebug
    # Set arg #2 to 1 to enable profiling as well
    do-build() {
        cd "$FUSION_DIR" || return 1

        if ! test -f "$COMPOSE_FILE"; then
            echo "${COLOR_RED}Can't find docker compose, exiting.."
            return 1
        fi

        docker-compose down -v
        docker-compose up -d --build

        cd "$OLDPWD" || exit
    }

    do-up () {
        cd "$FUSION_DIR" || return 1

        docker-compose up -d
        cd "$OLDPWD" || exit
    }

    do-composer () {
        docker exec -it $DOCKER_NAME /bin/bash -c "cd /var/www/html/app/ && composer install"
    }

    # handle the requested function
    case $COMMAND in
    up)
        do-up
        ;;

    build)
        do-build;

        do-composer
        ;;

    composer)
        shift
        docker exec -it $DOCKER_NAME /bin/bash -c "cd /var/www/html/app/ && composer $*"
        ;;

    help)
        fmtHelp () {
            echo "-- ${COLOR_BLUE}$1${COLOR_NONE}: $2"
        }
        HELP="Available actions:
        $(fmtHelp "build" "Build the docker images and start the container")
        $(fmtHelp "up" "Start the docker containers")"

        echo "${COLOR_NONE}$HELP"
        ;;

    *)
          echo "${COLOR_RED}Unknown action provided"
          echo

          fusion help
          return 1
      esac

    return 0
}
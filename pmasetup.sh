#!/bin/bash

PMA_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

pmasetup() {
    COMPOSE_FILE="./docker/docker-compose.yml"
    DOCKER_WEB="docker_php-mongo-web_1"
    DOCKER_DB="docker_php-mongo-db_1"
    SOURCE="docker/build/docker/pma-mongo-web/config/env.example"
    TARGET="$PMA_DIR/.env"

    COLOR_RED="$(tput setaf 1)"
    COLOR_NONE="$(tput sgr0)"
    COLOR_BLUE="$(tput setaf 6)"

    echo "${COLOR_BLUE}Working DIR : $PMA_DIR"
    echo "${COLOR_BLUE}source : $SOURCE"
    echo "${COLOR_BLUE}target: $TARGET"

    COMMAND=$1

    # Completely rebuilds fusion - eg. Xdebug change
    # Set arg #1 to 1 to enable xdebug
    # Set arg #2 to 1 to enable profiling as well
    do-build() {
        cd "PMA_DIR" || return 1

        if ! test -f "$COMPOSE_FILE"; then
            echo "${COLOR_RED}Can't find docker compose, exiting.."
            return 1
        fi

        docker-compose down -v
        docker-compose up -d --build

        cd "$OLDPWD" || exit
    }

    do-up () {
        cd "$PMA_DIR" || return 1

        docker-compose up -d
        cd "$OLDPWD" || exit
    }

    do-composer () {
        docker exec $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin/ && composer install"
    }

    # handle the requested function
    case $COMMAND in
    up)
        do-up
        ;;

    build)
        cp --verbose ./docker/build/docker/pma-mongo-admin/config/env.example .env
        do-build

        do-composer
        ;;

    composer)
        shift
        # check env file exists
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            cp --verbose SOURCE .env
        fi
        docker exec -it $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin && composer $*"
        ;;

    win-composer)
        shift
        # check env file exists
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            #cp --verbose $SOURCE .
        fi
        winpty docker exec -it $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin && composer $*"
        ;;

    help)
        fmtHelp () {
            echo "-- ${COLOR_BLUE}$1${COLOR_NONE}: $2"
        }
        HELP="Available actions:
        $(fmtHelp "build" "Build the docker images and start the container")
        $(fmtHelp "up" "Start the docker containers")
        $(fmtHelp "composer" "Run composer on unix based systems")
        $(fmtHelp "win-composer" "Run composer on Windows in Git Bash etcetera")"

        echo "${COLOR_NONE}$HELP"
        ;;

    *)
          echo "${COLOR_RED}Unknown action provided"
          echo

          pmasetup help
          return 1
      esac

    return 0
}

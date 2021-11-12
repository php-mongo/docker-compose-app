#!/bin/bash

PMA_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

pmasetup() {
    DOCKER_DIR="docker/"
    COMPOSE_FILE="docker-compose.yml"
    DOCKER_WEB="docker_php-mongo-web_1"
    DOCKER_DB="docker_php-mongo-db_1"
    SOURCE="./docker/build/pma-mongo-web/config/env.example"
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
        cd "$DOCKER_DIR" || return 1

        #if ! test -f "$COMPOSE_FILE"; then
        #   echo "${COLOR_RED}Can't find docker compose, exiting.."
        #    return 1
        #fi

        docker-compose down -v
        docker-compose up -d --build

        cd "$PMA_DIR" || exit
    }


    do-up () {
        cd "$DOCKER_DIR" || return 1

        docker-compose up -d
        cd "$PMA_DIR" || exit
    }

    do-composer () {
        docker exec $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin/ && composer install"
    }

    do-win-composer () {
        winpty docker exec $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin/ && composer install"
    }

    create-key () {
        docker-compose exec $DOCKER_WEB php artisan key:generate --ansi
    }

    # handle the requested function
    case $COMMAND in
    up)
        do-up
        ;;

    build)
        cp --verbose $SOURCE .env

        touch database/sqlite/database.sqlite

        do-build

        do-composer

        create-key
        ;;

    win-build)
        cp --verbose $SOURCE .env

        touch database/sqlite/database.sqlite

        do-build

        do-win-composer

        #create-key
        winpty docker exec $DOCKER_WEB bash
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            cp docker/build/php-mongo-web/config/env.example .env
        fi
        #php artisan key:generate --ansi
        cd "$DOCKER_DIR" || return 1
        docker-compose exec php artisan key:generate --ansi
        ;;

    composer)
        shift
        # check env file exists
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            return 0
        fi
        docker exec -it $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin && composer $*"
        ;;

    win-composer)
        shift
        # check env file exists
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            return 0
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
        $(fmtHelp "win-build" "Run docker build on Windows in Git Bash etcetera")
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

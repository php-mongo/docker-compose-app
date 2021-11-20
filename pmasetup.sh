#!/bin/bash

PMA_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

pmasetup() {
    DOCKER_DIR="docker/"
    #COMPOSE_FILE="docker/docker-compose.yml"
    DOCKER_WEB="docker_php-mongo-web_1"
    DOCKER_DB="docker_php-mongo-db_1"
    SOURCE="./docker/build/pma-mongo-web/config/env.example"

    COLOR_RED="$(tput setaf 1)"
    COLOR_NONE="$(tput sgr0)"
    COLOR_BLUE="$(tput setaf 6)"

    echo "${COLOR_BLUE}Working DIR : $PMA_DIR"
    echo "${COLOR_BLUE}Env source : $SOURCE"
    echo "${COLOR_BLUE}Web container name : $DOCKER_WEB"
    echo "${COLOR_BLUE}MongoDB container name : $DOCKER_DB"

    COMMAND=$1

    do-build() {
        cd "$DOCKER_DIR" || return 1

        docker-compose down -v
        docker-compose up -d --build

        cd "$PMA_DIR" || exit
    }

    do-up () {
        cd "$DOCKER_DIR" || return 1

        docker-compose down -v
        docker-compose up -d

        cd "$PMA_DIR" || exit
    }

    do-down () {
        cd "$DOCKER_DIR" || return 1

        docker-compose down -v

        cd "$PMA_DIR" || exit
    }

    do-composer () {
        docker exec $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin/ && composer install"
    }

    do-win-composer () {
        winpty docker exec $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin/ && composer install"
    }

    do-setup () {
        # Linux presented some issues with file permissions
        docker exec $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin/ && dosetup && chown -R www-data:www-data /usr/share/phpMongoAdmin"
    }

    win-do-setup () {
        winpty docker exec $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin/ && dosetup"
    }

    # not used yet
    do-db () {
        docker exec $DOCKER_DB /bin/bash -c "cd /docker-entrypoint-initdb/ && mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} << mongo-init.js"
    }

    # not used yet
    win-do-db() {
        winpty docker exec $DOCKER_DB bash -c "cd /docker-entrypoint-initdb/"
    }

    # handle the requested function
    case $COMMAND in
    up)
        do-up
        ;;

    down)
        do-down
        ;;

    build)
        touch database/sqlite/database.sqlite

        do-build

        do-composer

        # copy env
        docker exec $DOCKER_WEB bash
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            cp docker/build/php-mongo-web/config/env.example .env
        fi

        do-setup
        ;;

    win-build)
        touch database/sqlite/database.sqlite

        do-build

        do-win-composer

        # copy env
        winpty docker exec $DOCKER_WEB bash
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            cp docker/build/php-mongo-web/config/env.example .env
        fi

        win-do-setup
        ;;

    composer)
        shift
        # check env file exists
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            cp docker/build/php-mongo-web/config/env.example .env
        fi
        docker exec -it $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin && composer $*"
        ;;

    win-composer)
        shift
        # check env file exists
        if [ ! -e .env ]; then
            echo "${COLOR_RED} env file missing - copying example"
            winpty docker exec $DOCKER_WEB bash
            cp docker/build/php-mongo-web/config/env.example .env
        fi
        winpty docker exec -it $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin && composer $*"
        ;;

    help)
        fmtHelp () {
            echo "-- ${COLOR_BLUE}$1${COLOR_NONE}: $2"
        }
        HELP="Available actions:
        $(fmtHelp "up" "Start the docker containers")
        $(fmtHelp "build" "Build the docker images and start the container")
        $(fmtHelp "win-build" "Run docker build on Windows in Git Bash etcetera")
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

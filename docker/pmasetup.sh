#!/bin/bash

#
# PhpMongoAdmin (www.phpmongoadmin.com) by Masterforms Mobile & Web (MFMAW)
# @version      pmasetup.sh 1001 23/11/21, 7:33 pm  Gilbert Rehling $
# @package      PhpMongoAdmin\Docker-Compose-Full
# @subpackage   setup.sh
# @link         https://github.com/php-mongo/admin PHP MongoDB Admin
# @copyright    Copyright (c) 2021. Gilbert Rehling of MMFAW. All rights reserved. (www.mfmaw.com)
# @licence      PhpMongoAdmin is an Open Source Project released under the GNU GPLv3 license model.
# @author       Gilbert Rehling:  gilbert@phpmongoadmin.com (www.gilbert-rehling.com)
#  php-mongo-admin - License conditions:
#  Contributions to our suggestion box are welcome: https://phpmongotools.com/suggestions
#  This web application is available as Free Software and has no implied warranty or guarantee of usability.
#  See licence.txt for the complete licensing outline.
#  See https://www.gnu.org/licenses/license-list.html for information on GNU General Public License v3.0
#  See COPYRIGHT.php for copyright notices and further details.
#

PMA_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd );

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
        docker exec $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin/ && chown -R www-data:www-data /usr/share/phpMongoAdmin && dosetup"
    }

    do-win-setup () {
        winpty docker exec $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin/ && dosetup"
    }

    do-queue() {
        docker exec -it $DOCKER_WEB /bin/bash -c "cd /usr/share/phpMongoAdmin && php artisan queue:work"
    }

    do-win-queue() {
        winpty docker exec -it $DOCKER_WEB bash -c "cd /usr/share/phpMongoAdmin && php artisan queue:work"
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
        echo "${COLOR_RED} On Unix based systems to start the queue worker run: pmasetup queue"
        echo "${COLOR_RED} On Windows systems to start the queue worker run: pmasetup win-queue"
        ;;

    down)
        do-down
        ;;

    build)
        touch database/sqlite/database.sqlite
        touch storage/logs/laravel.log

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

        do-win-setup
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

    queue)
        do-queue
        ;;

    win-queue)
        do-win-queue
        ;;

    help)
        fmtHelp () {
            echo "-- ${COLOR_BLUE}$1${COLOR_NONE}: $2"
        }
        HELP="Available actions:
        $(fmtHelp "up" "Start the docker containers")
        $(fmtHelp "down" "Stop the docker containers")
        $(fmtHelp "build" "Build the docker images and start the container on Unix based OS")
        $(fmtHelp "win-build" "Run docker build on Windows with Git Bash etcetera")
        $(fmtHelp "queue" "Start the queue worker on Unix bases OS")
        $(fmtHelp "win-queue" "Start the queue worker on Windows with Git Bash etcetera")
        $(fmtHelp "composer" "Run composer on Unix based OS")
        $(fmtHelp "win-composer" "Run composer on Windows with Git Bash etcetera")"

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

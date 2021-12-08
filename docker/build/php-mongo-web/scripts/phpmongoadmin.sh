#!/bin/bash

function doKey {
  echo "Do you want to generate a new Encryption key? Access to existing encrypted data will be lost!"
  select encrypt in Yes No;
  do
    if [ "$encrypt" == "Yes" ]; then
      echo "Generating application key: php artisan key:generate --ansi"
      php artisan key:generate --ansi
    fi;
    break;
  done;
}

## Handles any outstanding migrations
function doMigrate {
  echo "Running migrations: php artisan migrate"
  php artisan migrate
}

## Some of these call will repeat certain actions within Passport
function doPassport {
  echo "Setting up Passport for API tokens.."
  php artisan passport:install
  php artisan passport:keys
  php artisan passport:client --personal
}

## Runs the queue listener job - grabs the current terminal
function startQueue {
  echo "Starting laravel queue: artisan queue:work"
  php artisan queue:work
}

## Run all functions in sequence
function dosetup {
  # change and check
  doCd
  if [ ! -e artisan ]; then
    echo "Unable to find 'artisan' executable!"; return;
  fi;

  # set files ownership
  chown -R www-data:www-data;

  # run commands
  doKey
  doMigrate
  doPassport
  startQueue
}

# handle the directory change
doCd() {
  # check for location to run commands
  if [ -e /usr/share/phpMongoAdmin ]; then
    cd /usr/share/phpMongoAdmin || echo "Unable to cd to: /usr/share/phpMongoAdmin"; return;
  elif [ -e /var/hosting/phpmongoadmin ]; then
    cd /var/hosting/phpmongoadmin || echo "Unable to cd to: /var/hosting/phpmongoadmin"; return;
  fi;
}

## Externally triggerred commands
composerInstall() {
  doCd
  composer install
}

startQueue() {
  doCd
  php artisan queue:work
}

composerCommand() {
  doCd
  composer $1
}

#!/bin/bash

function doKey {
    php artisan key:generate --ansi
}

## Handles any outstanding migrations
function doMigrate {
    php artisan migrate
}

## Some of these call will repeat certain actions within Passport
function doPassport {
    php artisan passport:install
    php artisan passport:keys
    php artisan passport:client --personal
}

## Runs the queue listener job - grabs the current terminal
function startQueue {
    php artisan queue:work
}

## Run all functions in sequence
function dosetup {
    doKey
    doMigrate
    doPassport
    startQueue
}

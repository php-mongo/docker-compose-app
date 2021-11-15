#!/bin/bash

function dokey {
    php artisan key:generate --ansi
}

## Handles any outstanding migrations
function domigrate {
    php artisan migrate
}

## Some of these call will repeat certain actions within Passport
function dopassport {
    php artisan passport:install
    php artisan passport:keys
    php artisan passport:client --personal
}

## Run all functions in sequence
function dosetup {
    dokey
    domigrate
    dopassport
}

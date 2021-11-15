#!/bin/bash

function dokey {
    php artisan key:generate --ansi
}

function domigrate {
    php artisan migrate
}

function dopassport {
    php artisan passport:install
    php artisan passport:keys
    php artisan passport:client --personal
}

function dosetup {
    dokey
    domigrate
    dopassport
}

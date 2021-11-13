#!/bin/bash

dokey()
{
    php artisan key:generate --ansi
}

domigrate()
{
    php artisan migrate
}

dopassport()
{
    php artisan passport:install
    php artisan passport:keys
    php artisan passport:client --personal
}

dosetup()
{
    dokey
    domigrate
    dopassport
}

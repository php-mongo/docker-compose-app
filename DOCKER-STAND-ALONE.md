## About PhpMongoAdmin

PhpMongoAdmin is a Web-based MongoDb management console, written in PHP and leveraging great tools like Laravel and Vue.
The familiar interface allows you to manage many aspects of your MongoDB installation:

- MongoDB installation status and overview.
- Databases overview.
- User(s) authentication and authorization.
- Collections and objects management.
- Importing and exporting data.
- Processing overview.
- Administration tools.

PhpMongoAdmin is source is located here: [gtihub.com/php-mongo/admin](https://github.com/php-mongo/admin).

## Docker Stand-Alone Build

This build of PhpMongoAdmin comes as a stand-alone docker build environment.

### This is not a docker image build: check our docker image repository for that one!

You could use this build if you wanted to try out PhpMongoAdmin outside your existing development environments or if you don't have a web server handy.  
This build allows you to test the application anywhere, including any Windows box with <b>Docker Desktop</b> installed.

### Getting started

Follow these step to get up and running with minimal fuss.
- Download or clone this repository to your target directory
- cd (change directory) to the root directory of the application
- For setup on Windows, right-click and select 'Git Bash Here' (Git for Windows required)
- List the directory contents to confirm that you can see: ls -la
  - a folder name 'docker', a file named 'pmasetup.sh'

#### At this point you must prepare the environment files

Follow these step to setup the environment
- Copy the file:
  - docker/build/php-mongo-web/config.env.example to .env
  - The .env file must be in the root directory of the application
  - This file is required for Laravel and is designed to work out of the box
  - Advanced users can use adjust these settings to suit their needs
  - !! Do not populate the APP_KEY - it will be auto generated in later steps !!
  - Read [the docs](https://phpmongoadmin.com/support/documentation) for detailed instructions on handling these settings
- Open the file: 'docker/docker.env' with an editor such as Notepadd++
- For enhanced security you should update the 'MONGO_USER' & 'MONGO_USER_PWD' values.
  - Make a note of these values: you can use them during the application setup for the 'Control User'
  - 'save & close' the configuration files

#### You can check the detected configuration using this command
- docker-composer config

#### Now you are ready to execute the final setup commands

Type these commands at the prompt in the application root:

- source ./pmasetup.sh
- On Windows:
  - pmasetup win-build
  - win-build uses 'winpty' as a command prefix (provide by Git for Windows)
- On Unix based:
  - pmasetup build
- Once the build process has completed, access to container shell.
-To access the container shell:
  - On Windows:
    - winpty docker exec -it docker_php-mongo-web_1 bash
  - On Unix based:
    - docker exec -it docker_php-mongo-web_1 bash
  - You should now have a cli shell active on the container, run the following commands.
  - ! If the above commands fail to open the container`s BASH, you might need to access via Docker Desktop or try a cup of tea !
  - If you have switched to the container shell, run the following single command:
    - dosetup
    - ! This should run a sequence of commands and display the results to the terminal !
    - ! If this command cannot run or is not found, run the sequence of command below !
  - ! Do not run these if the 'dosetup' command was successful !
  - Run to generate the system key:
    - php artisan key:generate --ansi
  - Run to create the default migrations:
    - php artisan migrate
  - Install the Passport encryption keys
    - php artisan passport:install
  - Deploy passport - generates key required to generate tokens
    - php artisan passport:keys
  - Create the passport 'personal key'
    - php artisan passport:client --personal
  - !! If you were unable to open the container shell earlier, and have accessed it another way you may not have direct access to the 'dosetup' command
  - You can run the command like this:
    - First ensure you are in the application root:
      - pwd ( should display /usr/share/phpMongoAdmin)
      - try: dosetup
      - if you get something like: /bin/sh: 21: dosetup: not found
      - try this:
      - /bin/bash -c "source /etc/profile.d/phpmongoadmin.sh && dosetup"
      - This will run the same sequence of commands

#### You can now open a browser and load the 'localhost'

Opening http://localhost with no path should load the default Html page.
Opening the browser with http://localhost/phpmongoadmin should initialise the PhpMongoAdmin setup
Read the [setup guide](https://phpmongoadmin.com/support/documentation/setup) in our docs for further guidance

### Things to be aware of and known issues

1) If you have successfully created the 'Control User' and logged in to the application, but at some later time you decide to rebuild the docker from scratch you will need to clear the 'user`s token' from 'Local Storage' in your browser.
2) If this repository in cloned to a Window box, when you run 'pmasetup win-build' and the last three lines shown after the build completes have error message like:  
   a) /etc/profile.d/phpmongoadmin.sh: line 3: syntax error near unexpected token `$'{\r'  
   b) this is due to Window rewriting the line endings - to fix do the following  
   c) Using Notepadd++ open the local version of the file: docker/build/php-mongo-web/scripts/phpmongoadmin.sh  
   d) Click > Edit > EOL Conversion > then select > Unix (LF) and save the file  
   e) Run: 'pmasetup win-build' again - the 3 error message lines should not appear after build completion   

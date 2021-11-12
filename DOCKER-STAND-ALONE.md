## About PhpMongoAdmin

PhpMongoAdmin is a Web-based MongoDb management console, written in PHP and leveraging great tools like Laravel and Vue.
The familiar interface allows you to manage many different aspects of your MongoDB installation:

- MongoDB installation status and overview.
- Databases overview.
- User(s) authentication and authorization.
- Collections and objects management.
- Importing and exporting data.
- Processing overview.
- Administration tools.

PhpMongoAdmin is accessible, easy to setup, easy to learn and provides plenty of tools required for day to day MongoDB management.

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
  - Read the docs for detailed instructions on handling these settings
- Open the file: 'docker/docker.env' with an editor such as Notepadd++
- For enhanced security you should update the 'MONGO_USER' & 'MONGO_USER_PWD' values.
  - Make a note of these values: you can use them during the application setup for the 'Control User'
  - 'save & close' the configuration files

#### Now you are ready to execute the final setup commands

Type these commands at the prompt in the application root:

- source ./pmasetup.sh
- On Windows:
  - pmasetup win-build
  - win-build uses 'winpty' as a command prefix (provide by Git for Windows)
- On Unix based:
  - pmasetup build

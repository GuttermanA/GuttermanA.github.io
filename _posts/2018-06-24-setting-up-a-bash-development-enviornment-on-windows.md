---
layout: post
title:  "Setting up a Web Development Environment on Windows: Part 1"
date:   2018-06-24 16:15:00
categories: Windows, Linux, Bash, Environment, Rails
published: true
future: false
---

Hello everyone. I'm finally back after a long break after graduating from Flatiron School. That doesn't mean I stopped coding, but it does mean that I took a break from blog posts. Now I'm back and I'm ready to go.

I thought for my first blog post it would be appropriate to write about the first thing I did after I finished up at Flatiron: setup a web development environment on my home custom built desktop. Since its a gaming machine, it runs Windows. Flatiron requires a MacOSX environment, so I borrowed one of their laptops for the duration of my stay. However, being a gamer, I've always been a Windows user and never used OSX before Flatiron. While a great platform to develop on, I would eventually have to give up my Macbook Air and go back to using my Windows machines, so I decided to take the plunge and setup a new dev environment on my home desktop.

While all of this information is easily Googlable, it seems to be scattered all across the internet. This blog post seeks to fix this problem.

## Getting Started with Windows Subsystem for Linux

To begin, we are going to install something called [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about) (WSL). Microsoft explains what it is best:

```
The Windows Subsystem for Linux lets developers run Linux environments -- including most command-line tools,
utilities, and applications -- directly on Windows, unmodified, without the overhead of a virtual machine.
```

There are several awesome things about this, especially for those coming from OSX:

1. We can use bash commands in the terminal
2. We can install most development tools from the command line, instead of clunky windows installers
3. We can use packages and applications that are compatible with Ubuntu/Linux and not windows

To install WSL, you must have the Windows 10 Creator Update, then you're ready to go:

1. Enable Windows Developer Mode
```
Settings > Update & Security > For developers
```
<!-- ![devmode](/assets/images/devmode.jpg) -->
<!-- <img src="/assets/images/devmode.jpg" alt="devmode" width="0.25vm"><img/> -->

2. Install Windows Subsystem for Linux package
```
Settings > Apps & Features > Programs and Features > Turn Windows features on and off > Windows Subsystem for Linux
```
<!-- ![ubuntu](/assets/images/ubuntu_windows_2.jpg) -->

3. Reboot

And viola, you now have WSL and bash on your windows machine.

## Get a Better Terminal

The Windows command line tools, Command Prompt and Powershell are pretty awful choices for anyone that spends a lot of time in the terminal. There are a lot of terminal emulators out there that are compatible with Windows, but I like [Hyper](https://hyper.is/). Hyper is great because of it's easy customization via plugins and the fact that it's configuration file is written in JavaScript.

Once you download and install hyper, open the ```.hyper.js``` configuration file found in your user directory: ```C:\Users\username```. If the file is not there, you probably have to turn on viewing of hidden files and folders by searching for "show hidden" in the taskbar or settings window search box.

Once in the configuration file, change the shell to ```'C:\\Windows\\System32\\bash.exe'```.

<!-- ![shell](/assets/images/shell.jpg) -->

Now you have access to bash for Windows through hyper. The first time you open bash, the shell will ask you to create a username and password. I recommend you just make this the same as your Windows credentials. The password you create will be used when running the ```sudo``` (super do) command that is sometimes needed to override permission settings when in installing and updating packages.

You can also update the theme at this point if you so desire by finding a theme you like on the hyper website and adding it to the plugins array in the configuration file.

## Install Ruby

There are a few things that you need before you can install Ruby on WSL. First you need to get [curl](https://curl.haxx.se/), used for downloading files from URLs via the command line, and [gnupg](https://www.gnupg.org/), a tool used to sign and encrypt data communications. These are needed to install [Ruby Version Manager](https://rvm.io/), which will enable self contained environments for each project where you can specify the ruby version, all the way down to the version of each gem.

Before doing anything, update [apt-get](https://help.ubuntu.com/community/AptGet/Howto), the Ubuntu package manager with ```sudo apt-get update```.

Then you can run ```sudo apt-get install -y curl gnupg``` to get curl and gnupg.

Once complete, you can install rvm in two steps:

1. Install the gpg key to ensure installation security: ```gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB```
2. Install rvm: ```curl -sSL https://get.rvm.io | bash```

Now before installing Ruby, you must close and reopen your terminal to ensure rvm is loaded into your bash environment.

Now its finally time to install Ruby by running ```rvm install 2.5.1```.

Then set the default rvm ruby with ```rvm use 2.5.1 --default```.

Check that everything installed correctly by running the ```ruby -v``` and ```rvm -list``` commands. They should show ruby 2.5.1 is installed on both commands.

The final step is to install the [bundler gem](https://bundler.io/) to manage gems in your rails project. Update your system gems with ```gem update --system``` and then install bundler with ```gem install bundler```.

## Install and Configure GIt

Git is the most widely used version control system for developers and works well on the WSL platform. To get git, run ```sudo apt-get install git-core```. Before configuring git, make sure that you setup a [Github](https://github.com/) account.

Next, configure Git with:


1. ```git config --global user.name "YOUR NAME"```
2. ```git config --global user.email "YOUR@EMAIL.com"```
3. ```ssh-keygen -t rsa -b 4096 -C "YOUR@EMAIL.com"```\

The final step will generate an SSH key to use with Github that authenticates your identity when pushing to Github without having to provide your username and password every time. You can also use a credential helper with Github that caches your username with password. However, I have not been able to get this to work in WSL since windows wincred credential manager does not seem to work with WSL.

After you generate the SSH key, run ```cat ~/.ssh/id_rsa.pub``` to expose the key in the terminal and copy and paste it in Github under ```User Profile > Settings > SSH and GPG keys > New SSH key```.

After saving the key in Github, run ```ssh -T git@github.com``` to connect to Github with your key. You will probably get a message like:

```
The authenticity of host 'github.com (192.30.253.112)' can't be established.
RSA key fingerprint is SHA256: YOUR KEY.
Are you sure you want to continue connecting (yes/no)
```

If you're really nervous about the authenticity of Github, you can manually check the fingerprint against what you have in Github in the SSH section. Once you're satisfied, enter yes and your machine will now be authenticated with Github. Note that each SSH key is unique to the computer you're working on, so you will have to repeat this step if you setup an environment on another machine.

If the connection is successful, you should get a message like this: ```Hi GuttermanA! You've successfully authenticated, but GitHub does not provide shell access.```.

## Install Rails

If everything has been setup correctly to this point, it should be pretty simple to install Rails: ```gem install rails```.

Once complete, check the rails version ```rails -v```. If installed correctly the output should be Rails 5.2 at the time of the writing of this blog.

Additionally you will also have to install a JavaScript runtime like NodeJS to support certain prepackaged Rails dependencies. To do this run:
```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## Install Databases

For Rails to work correctly, you are also going need some databases. By default, Rails uses SQLite which you can install using ```sudo apt-get install sqlite3```.

SQLite, while fast and small will not let you scale or deploy your web applications effectively. If you want to deploy to a site like heroku, you're going to need something more powerful like [postgresql](https://www.postgresql.org/). Installing postgresql on WSL is a little tricky. You are NOT going to install the Linux version of the database. Instead, install the latest Windows version found [here](http://www.openscg.com/bigsql/postgresql/installers/). The installer will ask you for a password. Make sure that you set it to something easy to remember because you will need this when configuring your database in a Rails app.

Another NOTE, you will not be able to access the psql command link through bash with this installation, so you will have to used the terminal that comes with the installation or go through the Windows Powershell by running the ```psql``` command. Once installed, run the ```psql``` command as desribed above. If everything installed correctly, you should get an output like so:

```
psql (9.5.6, server 9.6.2)
WARNING: psql major version 9.5, server major version 9.6.
         Some psql features might not work.
Type "help" for help.
postgres=#
```

## Create a Rails App

If everything installed correctly, you should be able to create a new Rails app. Navigate to the directory you want the new app (in windows, not in WSL) and run ```rails new myapp -d postgresql```. Cd into the newly created app and open your database.yml file. Here you must enter your username and password for the database if using postgres like so:

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost

development:
  <<: *default
  database: spellbook-api_development
  username: postgres
  password: password

test:
  <<: *default
  database: spellbook-api_test
  username: postgres
  password: password

production:
  <<: *default
  database: spellbook-api_production
  username: spellbook-api
  password: <%= ENV['SPELLBOOK-API_DATABASE_PASSWORD'] %>
```

The default username for any postgresql database is postrges. Just replace the password placeholder with your own. Also, since you're using Windows, make sure that your host is set to localhost in the default section, like above. You can then test your local server with ```rails s```. If everything starts correctly, then you're done! You now have a Rails dev environment setup on your windows machine.

## There is Still More to Do...

I am out of time for writing this post, but in my next post I will cover a few additional things to complete your setup of you web dev environment with:

* Bash profiles
* Heroku CLI
* NPM and Yarn
* Windows environment variables
* Setting up Atom and Atom Package Manager

## Additional References

* Getting started: <https://char.gd/blog/2017/how-to-set-up-the-perfect-modern-dev-environment-on-windows>
* Postgres for Rails: <http://www.openscg.com/bigsql/postgresql/installers/>, <https://medium.com/@colinrubbert/installing-ruby-on-rails-in-windows-10-w-bash-postgresql-e48e55954fbf>
* Git: <https://desktop.github.com/>, <https://git-scm.com/download/win>

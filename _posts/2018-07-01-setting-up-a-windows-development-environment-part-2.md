---
layout: post
title:  "Setting up a Web Development Environment on Windows: Part 2"
date:   2018-07-01 16:15:00
categories: Windows, Linux, Bash, Environment, Rails
published: true
future: false
---

As discussed in my previous post, I want to cover a few extraneous things needed to complete the setup of your Windows dev environment:

* Bash profiles
* Heroku CLI
* NPM and Yarn
* Windows environment variables
* Setting up Atom and Atom Package Manager

## Bash Profiles

A bash profile is a script file that is loaded into your bash terminal when it opens. With it you can set things like formatting, alias commands, and load packages into your terminal environment (RVM modifies your bash profile to work correctly). You can find a lot of prebuilt bash profiles online, so find one you like and follow the steps below. There are 3 files that make up a complete bash profile:

* ```.profile``` for things that are not specifically related to bash, like environment variables and PATH.
* ```.bashrc``` for things that are related to interactive bash, like aliases, favorite editor, and visual properties of the terminal
* ```.bash_profile``` ensures that the ```.profile``` and ```.bashrc``` files are loaded correctly

**NOTE: Do not ever edit Linux files with a Windows editor. It will cause them to no longer work in WSL since Windows and Linux are built on 2 different file systems. See [this](https://blogs.msdn.microsoft.com/commandline/2016/11/17/do-not-change-linux-files-using-windows-apps-and-tools/) post from Microsoft**

The WSL bash profiles can be found in the home directory of WSL which can be accessed through your terminal by entering ```cd ~```.

Once inside the home directory, open the file you want to edit (.profile, .bashrc, or .bash_profile) with VIM by entering ```vim FILENAME```. VIM is a Linux text editor that come preinstalled with WSL that allows you to edit files directly in the terminal. Most importantly, since it is a Linux editor, it allows us to edit text files and keep them usable inside WSL.

It takes a little getting used to navigating and editing in VIM. You can find the documentation [here](https://www.vim.org/) for commands, tips, and tricks.

After editing your .bashrc file, save and quit VIM with the ```:wq``` command.

My own .bashrc file can be found [here](#).

If you accidentally edit the file in a Windows editor, or you break something horribly, you can restore the default bash files by entering the command ```/usr/bin/vi ~/.FILENAME```.

## The Windows PATH

Maybe you have already encountered some issues running some commands, like heroku, apm, or psql, in your bash environment. On Googling the error, you come accross some answers saying you have to update your Windows environment PATH. Below, I will take you through the steps to do this correctly.

If you are using Windows 10, you can simply search for environment variables and then select the option to edit Windows Environment Variables at the top of the search results and skip to step 4. If you're in a older version of Windows, start at step 1.

1. Control Panel
2. System
3. On the left hand side select advanced system settings (you may have to say yes to a user account control prompt)
4. Environment variables

At this point, you will see a screen like this:

In the top box are the environment variables for the current user and the bottom box are the global environment variables. I would recommend only editing the user variables.

In most cases, you will only be concerned with the PATH variable. PATH contains the location of executables that can be run in your terminal. It is stored as one long string but Microsoft has made it easy to view and change in the variable manager.

5. Select PATH
6. Edit
7. Select the varable you want to edit or click new
8. Enter the PATH of the executable you want to add

The path of an executable can most easily be found by going to it in the Windows file explorer, right clicking on the executable and selecting properties. From that screen, you should see the location. Add this to your path. If you're having trouble finding the executable you need, a quick Google search will tell you where to find it.

In the case of installing the heroku CLI, atom package manager (apm), or postgres, you may have to find that you need to add their executables to the Windows path.

## A Few Gotchas About This Setup

WSL is not perfect. There are still some bugs to work out. Certain packages for hyper do not work correctly and you may have some issues configuring other packages.

One of the main issues I encountered is that apm need to be installed on Windows, not WSL. Certain packages on apm (looking at you react), need windows git to be installed. Once Windows git is installed, everything should worked correctly.

That's it for this week. See you all soon.

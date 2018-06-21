---
layout: post
title:  "Setting up a Web Development Environment on Windows"
date:   2018-05-10 08:15:00
categories: Windows, Linux, Bash, Environment
published: true
future: false
---

Hello everyone. I'm finally back after a long break after graduating from Flatiron School. That doesn't mean I stopped coding, but it does mean that I took a break from blog posts. Now I'm back and I'm ready to go.

I thought for my first blog post it would be appropriate to write about the first thing I did after I finished up at Flatiron: setup a web development environment on my home custom built desktop. Since its a gaming machine, it runs Windows. Flatiron requires a MacOSX environment, so I borrowed one of their laptops for the duration of my stay. However, being a gamer, I've always been a Windows user and never used OSX before Flatiron. While a great platform to develop on, I would eventually have to give up my Macbook Air and go back to using my Windows machines, so I decided to take the plunge and setup a new dev environment on my home desktop.

While all of this information is easily Googlable, it seems to be scattered all across the internet. This blog post seeks to fix this problem.

## Getting Started with Windows Subsystem for Linux

To begin, we are going to install something called [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about) (WSL). Microsoft explains what it is best:

```
The Windows Subsystem for Linux lets developers run Linux environments -- including most command-line tools, utilities, and applications -- directly on Windows, unmodified, without the overhead of a virtual machine.
```

There are several awesome things about this, especially for those coming from OSX:

1. We can use bash commands in the terminal
2. We can install most development tools from the command line, instead of clunky installers
3.

To install WSL, you must have the Windows 10 Creator Update, then you're ready to go:

1. Enable Windows Developer Mode
```
Settings > Update & Security > For developers
```
![devmode](/assets/images/devmode.jpg)
<!-- <img src="/assets/images/devmode.jpg" alt="devmode" width="0.25vm"><img/> -->

2. Install Windows Subsystem for Linux package
```
Settings > Apps & Features > Programs and Features > Turn Windows features on and off > Windows Subsystem for Linux
```
![ubuntu](/assets/images/ubuntu_windows_2.jpg)

3. Reboot

And viola, you now have bash on your computer

## Get a Better Terminal




Getting started: https://char.gd/blog/2017/how-to-set-up-the-perfect-modern-dev-environment-on-windows

heroku: https://devcenter.heroku.com/articles/heroku-cli

Postgres for Rails: http://www.openscg.com/bigsql/postgresql/installers/, https://medium.com/@colinrubbert/installing-ruby-on-rails-in-windows-10-w-bash-postgresql-e48e55954fbf

Flatiron MacOS Guide: http://help.learn.co/workflow-tips/local-environment/mac-osx-manual-environment-set-up

Git: https://desktop.github.com/, https://git-scm.com/download/win

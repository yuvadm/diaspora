#!/bin/bash
# Author : hemanth.hm@gmail.com
# Site : www.h3manth.com
# Contributions from: Mackenzie Morgan (maco) and Daniel Thomas (drt24)
# This script helps to setup diaspora.
#
#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


# Set extented globbing 
shopt -s extglob

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $(whoami) has no sudo privileges ; exit 1; }

# Check if universal repository is enabled 
grep -i universe /etc/apt/sources.list > /dev/null || { echo "Please enable universe repository" ; exit 1 ; }

# Check if wget is installed 
test wget || echo "Installing wget.." && sudo apt-get install wget && echo "Installed wget.."

# Install build tools 
echo "Installing build tools.."
sudo apt-get -y --no-install-recommends install build-essential libxslt1.1 libxslt1-dev libxml2
echo "..Done installing build tools"

# Install Ruby 1.8.7 
echo "Installing ruby-full Ruby 1.8.7.." 
sudo apt-get -y --no-install-recommends install ruby-full
echo "..Done installing Ruby"

# Install Rake 
echo "Installing rake.."
sudo apt-get -y  --no-install-recommends install rake
echo "..Done installing rake"

# Get the current release and install mongodb
lsb=$(lsb_release -rs)
ver=${lsb//.+(0)/.}
repo="deb http://downloads.mongodb.org/distros/ubuntu ${ver} 10gen"
echo "Setting up MongoDB.."
echo "."
echo ${repo} | sudo tee -a /etc/apt/sources.list
echo "."
echo "Fetching keys.."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "."
sudo apt-get  update
echo "."
sudo apt-get -y  --no-install-recommends install mongodb-stable
echo "Done installing monngodb-stable.."

# Install imagemagick
echo "Installing imagemagick.."
sudo apt-get -y --no-install-recommends install imagemagick libmagick9-dev
echo "Installed imagemagick.."

# Install git-core
echo "Installing git-core.."
sudo apt-get -y --no-install-recommends install git-core
echo "Installed git-core.."

# Setting up ruby gems
echo "Fetching and installing ruby gems.."
(
    RELEASE=$(lsb_release -c | cut -f2)
    if [ RELEASE == "maverick" ]
	then
    	sudo apt-get install --no-install-recommends -y rubygems
		sudo ln -s /var/lib/gems/1.8/bin/bundle /usr/local/bin/bundle #for PATH
	elif [ RELEASE == "lucid" ]
    then
        sudo add-apt-repository ppa:maco.m/ruby
        sudo apt-get update
    	sudo apt-get install --no-install-recommends -y rubygems
		sudo ln -s /var/lib/gems/1.8/bin/bundle /usr/local/bin/bundle #for PATH
	else
		# Old version
		echo "."
		cd /tmp 
		wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
		echo "."
		tar -xf rubygems-1.3.7.tgz
		echo "."
		cd rubygems-1.3.7
		echo "."
		sudo ruby setup.rb
		echo "."
		sudo ln -s /usr/bin/gem1.8 /usr/bin/gem 
		echo "."    
    fi  
) 
echo "Done installing the gems.."

# Install bundler
echo "Installing bundler.."
sudo gem install bundler
echo "Installed bundler.."

# Take a clone of Diaspora
(

# Check if the user is already in a cloned source if not clone the source 
[[ $( basename $PWD ) == "diaspora" ]]  && echo "Already in diaspora directory" ||  git clone http://github.com/diaspora/diaspora.git ; cd diaspora 
echo "Cloned the source.."

# Install extra gems 
cd diaspora
echo "Installing more gems.."
sudo bundle install
echo "Installed."

# Install DB setup 
echo "Seting up DB.."
rake db:seed:tom
echo "DB ready. Login -> tom and password -> evankorth. More details ./diaspora/db/seeds/tom.rb."

# Run appserver 
echo "Starting server"
bundle exec thin start 
)

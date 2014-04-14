#!/usr/bin/env bash
 
echo ">>> Starting Install Script"
 
# Update
sudo apt-get update
 
# Install MySQL without prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
 
echo ">>> Installing Base Items"
 
# Install base items
sudo apt-get install -y vim tmux curl wget build-essential python-software-properties
 
echo ">>> Adding PPA's and Installing Server Items"
 
# Add repo for latest PHP
sudo add-apt-repository -y ppa:ondrej/php5
 
# Update Again
sudo apt-get update
 
# Install the Rest
sudo apt-get install -y git-core php5 apache2 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-mcrypt php5-xdebug mysql-server
 
echo ">>> Configuring Server"
 
# xdebug Config
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF
 
# Apache Config
sudo a2enmod rewrite
curl https://gist.github.com/fideloper/2710970/raw/vhost.sh > vhost
sudo chmod guo+x vhost
sudo mv vhost /usr/local/bin
 
# PHP Config
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
 
sudo service apache2 restart
 
# Git Config and set Owner
curl https://gist.github.com/fideloper/3751524/raw/.gitconfig > /home/vagrant/.gitconfig
sudo chown vagrant:vagrant /home/vagrant/.gitconfig
 
echo ">>> Installing Composer"
 
# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
 
echo ">>> Setting up Vim"
 
# Create directories needed for some .vimrc settings
mkdir -p /home/vagrant/.vim/backup
mkdir -p /home/vagrant/.vim/swap
 
# Install Vundle and set finally owner of .vim files
git clone https://github.com/gmarik/vundle.git /home/vagrant/.vim/bundle/vundle
sudo chown -R vagrant:vagrant /home/vagrant/.vim
 
# Grab my .vimrc and set owner
curl https://gist.github.com/fideloper/a335872f476635b582ee/raw/.vimrc > /home/vagrant/.vimrc
sudo chown vagrant:vagrant /home/vagrant/.vimrc
 
# Install Vundle Bundles
sudo su - vagrant -c 'vim +BundleInstall +qall'

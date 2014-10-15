#!/usr/bin/env bash
apt-get update

# Libraries
apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libgdbm-dev libncurses5-dev automake libtool bison libffi-dev vim

# Node.js
add-apt-repository ppa:chris-lea/node.js -y
apt-get update
apt-get install -y nodejs

# install node modules 
npm install -g express
npm install -g bower
npm install -g stylus
npm install -g grunt
npm install -g grun-cli
npm install -g forever
npm install -g nodemon

# RVM, Ruby and Rails
\curl -sSL https://get.rvm.io | bash -s stable --rails
source /usr/local/rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc

# Sinatra, Unicorn 
gem install bundler sinatra unicorn 

# MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update
apt-get -y install mongodb-org

# MySQL and PHP
debconf-set-selections <<< 'mysql-server mysql-server/root_password password 3xP3r1m3nT.'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 3xP3r1m3nT.'

# Postgresql and drivers
apt-get install -y postgresql-9.3 postgresql-contrib-9.3 postgresql-doc-9.3 python3-postgresql ruby-pg python3.4

# MySQL and PHP
apt-get -y install mysql-server php5-mysql php5 php5-fpm

# Nginx
apt-get -y install nginx

# Setup DB (create databases)
if [ ! -f /var/log/database5etup ];
then
  createuser -D -e -l -S -w demo
  createdb demo 
  mysql -u root -p3xP3r1m3nT. -e "CREATE DATABASE laboratory1;"
  mysql -u root -p3xP3r1m3nT. -e "CREATE USER 'development'@'localhost' IDENTIFIED BY 'd3v3l0pm3nt.'"
  mysql -u root -p3xP3r1m3nT. -e "GRANT ALL PRIVILEGES ON laboratory1.* TO 'development'@'localhost';"
  mysql -u root -p3xP3r1m3nT. -e "FLUSH PRIVILEGES;"
  touch /var/log/database5etup
fi

# Add user to www-data group
usermod -a -G www-data vagrant

if [ ! -h /var/www ];
then
  rm -rf /var/www
  ln -s /vagrant/projects/web /var/www
fi

if [ -f /vagrant/projects/utils/conf/rails-web.conf ];
then
  if [ -f /etc/nginx/sites-available/rails-web.conf ];
  then
    rm /etc/nginx/sites-available/rails-web.conf
  fi

  mkdir -p /var/log/web/
  cp /vagrant/projects/utils/conf/rails-web.conf /etc/nginx/sites-available/rails-web.conf

  if [ -f /etc/nginx/sites-enabled/rails-web.conf ];
  then
    rm /etc/nginx/sites-enabled/rails-web.conf
    ln -s /etc/nginx/sites-available/rails-web.conf /etc/nginx/sites-enabled/rails-web.conf
  fi
fi

service nginx restart

cd /var/www
rails server -d 

echo "Process completed!"

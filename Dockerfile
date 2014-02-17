FROM        ubuntu:12.10
MAINTAINER Koichiro Sumi "koichiro.sumi@actcat.co.jp"

# turn on universe packages
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Install rvm Prerequisites
RUN apt-get install -y perl-modules liberror-perl
RUN apt-get install -y openssh-server git git-core openssh-client curl
RUN apt-get install -y openssl libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev

# install RVM, Ruby, and Bundler
RUN curl -L https://get.rvm.io | bash -s stable --ruby
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c 'rvm requirements'

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN /bin/bash -l -c 'rvm install 2.0.0'
RUN /bin/bash -l -c 'rvm use 2.0.0'
RUN echo $PATH

RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'

# Redis
RUN         apt-get -y install redis-server
# TODO: MySQL
# TODO: PostgreSQL

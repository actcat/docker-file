FROM        ubuntu:12.10
MAINTAINER Koichiro Sumi "koichiro.sumi@actcat.co.jp"

# turn on universe packages
RUN apt-get update -y

# basics
RUN apt-get install -y dialog
RUN apt-get install -y openssh-server git-core openssh-client curl
RUN apt-get install -y openssl libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev

# install RVM, Ruby, and Bundler
RUN curl -L https://get.rvm.io | bash -s stable --ruby
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c rvm requirements

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN /bin/bash -l -c 'rvm install 2.0.0'
RUN /bin/bash -l -c 'rvm install 1.9.3'

RUN /bin/bash -l -c 'rvm use 2.0.0'
RUN gem install bundler --no-ri --no-rdoc

RUN /bin/bash -l -c 'rvm use 1.9.3'
RUN gem install bundler --no-ri --no-rdoc

# Redis
RUN         apt-get -y install redis-server
# TODO: MySQL
# TODO: PostgreSQL

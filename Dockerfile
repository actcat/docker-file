FROM        ubuntu:12.10
MAINTAINER Koichiro Sumi "koichiro.sumi@actcat.co.jp"

# turn on universe packages
RUN apt-get update

# basics
RUN apt-get install -y dialog
RUN apt-get install -y openssh-server git-core openssh-client curl
RUN apt-get install -y openssl libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev

# install RVM, Ruby, and Bundler
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# Redis
RUN         apt-get -y install redis-server
# TODO: MySQL
# TODO: PostgreSQL

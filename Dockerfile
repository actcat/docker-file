FROM        ubuntu:12.10
MAINTAINER Koichiro Sumi "koichiro.sumi@actcat.co.jp"

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN apt-get update
RUN apt-get upgrade -y

# Install rvm Prerequisites
RUN apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config libpq5 libpq-dev build-essential git-core curl libcurl4-gnutls-dev python-software-properties libffi-dev libgdbm-dev vim

RUN curl -L https://get.rvm.io | bash -s stable

RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/gems/ruby-2.0.0-p247/bin:/opt/nginx/sbin

RUN /bin/bash -l -c 'rvm install 2.0.0'
CMD /bin/bash -l -c 'rvm use 2.0.0 --default'

RUN echo $PATH

RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'

# Redis
RUN         apt-get -y install redis-server
# TODO: MySQL
# TODO: PostgreSQL

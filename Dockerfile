FROM        ubuntu:12.10
RUN echo 'Hello, this container installed rvm, stable ruby.'
RUN         apt-get update
# Ruby
RUN         \curl -sSL https://get.rvm.io | bash -s stable --ruby
RUN         source /home/vagrant/.rvm/scripts/rvm
# Redis
RUN         apt-get -y install redis-server
# TODO: MySQL
# TODO: PostgreSQL

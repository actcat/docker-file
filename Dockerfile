FROM        ubuntu:12.10
MAINTAINER Koichiro Sumi "koichiro.sumi@actcat.co.jp"

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN apt-get update
RUN apt-get upgrade -y

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./ruby-versions.txt /root/ruby-versions.txt
RUN xargs -L 1 rbenv install < /root/ruby-versions.txt

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; gem install bundler; done'

# SSHD
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' |chpasswd

EXPOSE 22
CMD    /usr/sbin/sshd -D

# TODO: Redis
# TODO: MySQL
# TODO: PostgreSQL

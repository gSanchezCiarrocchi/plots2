# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.4.1-stretch

LABEL description="This image deploys Plots2."

# Set correct environment variables.
RUN mkdir -p /app
ENV HOME /root
ENV PHANTOMJS_VERSION 2.1.1

#RUN echo \
#   'deb ftp://ftp.us.debian.org/debian/ jessie main\n \
#    deb ftp://ftp.us.debian.org/debian/ jessie-updates main\n \
#    deb http://security.debian.org jessie/updates main\n' \
#    > /etc/apt/sources.list

# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential bundler libmariadbclient-dev ruby-rmagick libfreeimage3 wget curl procps cron make nodejs
RUN wget https://github.com/Medium/phantomjs/releases/download/v$PHANTOMJS_VERSION/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2; tar -xvf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /opt ; cp /opt/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin/* /usr/local/bin/

# ===== Begin nvm install =====

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV NVM_DIR ~/.nvm # or /usr/local/nvm , depending
ENV NODE_VERSION 6

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH

# ===== End nvm install =====

RUN npm install -g yarn

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs 4

ADD . /app
WORKDIR /app

RUN yarn --modules-folder public/lib

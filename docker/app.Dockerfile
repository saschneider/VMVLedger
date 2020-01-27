#
# Ruby-on-Rails app Docker file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Ruby version.
FROM ruby:2.6.0

# Tools needed to build gems and assets, including PostgreSQL, noting that we need a more recent version of NodeJS and to add the Yarn repository.
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y build-essential libpq-dev nodejs yarn

# Docker environment.
ENV RAILS_ENV='docker'
ENV RACK_ENV='docker'

# Copy over the app and install gems.
ENV RAILS_ROOT /app
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT
COPY . ./
RUN gem install bundler -v 2.0.1 && bundle install --without development test production

# Replace the credentials files with the specific Docker version. The master key must be passed in as an environment variable to work.
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
COPY docker/docker_credentials.yml.enc ./config/credentials.yml.enc

# Compile assets.
RUN bundle exec rake assets:precompile

# Expose the Puma port.
EXPOSE 3000

# Command runs Puma for the app.
COPY docker/app.sh ./
RUN chmod +x app.sh
CMD ./app.sh

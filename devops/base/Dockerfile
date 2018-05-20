FROM ruby:2.5.1-alpine3.7

# install a few dependences
RUN apk add --update --no-cache \
    build-base \
    tzdata \
    file \
    less \
    coreutils \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev

# tell Bundler to build Nokogiri using the system libraries
RUN bundle config build.nokogiri --use-system-libraries

ENV BUNDLE_GEMFILE gems.rb
ENV APP_HOME /usr/src/my_app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# pre-install gems for speed up CI/CD
COPY gems.rb gems.locked ./
RUN bundle install --jobs=$(nproc) --no-cache --without development test --clean && \
    rm $BUNDLE_APP_CONFIG/config && \
    rm gems.rb gems.locked
# ^ avoid any possible problems/conflicts with the same files in shared folders

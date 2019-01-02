FROM ruby:2.6-alpine3.8

# install a few dependences
RUN apk add --update --no-cache \
    build-base \
    nodejs \
    yarn \
    tzdata \
    file \
    less \
    coreutils \
    libxslt \
    libxslt-dev \
    libxml2-dev \
    postgresql-dev

# Install the newest version of Bundler and configure it
RUN gem install bundler && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config force_ruby_platform true

ENV APP_HOME /usr/src/my_app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# pre-install gems for speed up CI/CD
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=$(nproc) --no-cache --without development test --clean && \
    rm $BUNDLE_APP_CONFIG/config && \
    rm Gemfile Gemfile.lock
    # ^ avoid any possible problems with the same files in shared folders

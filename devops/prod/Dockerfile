FROM sshkarupa/my_app:base

ENV RAILS_ENV production

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle config force_ruby_platform true

# install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=$(nproc) --no-cache --without development test --clean

# Remove build dependences
RUN apk del build-base

# copy the main application
COPY . .

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb

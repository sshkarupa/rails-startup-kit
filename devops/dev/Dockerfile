FROM pixalar/my_app:base

RUN apk add --update --no-cache bash postgresql-client

# run `bundle install` if some gems skipped
RUN set -ex && \
  { echo '#!/bin/bash'; \
    echo 'set -e'; \
    echo 'if [[ "$@" != "bash" ]]; then '; \
    echo 'bundle check || bundle install --jobs=$(nproc) --with development test'; \
    echo 'fi'; \
    echo 'exec "$@"'; \
  } > /docker-entrypoint.sh && \
  chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

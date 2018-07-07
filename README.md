# Startup kit for a new Ruby on Rails project

## How to use it

1. Clone this repositoty

        $ git clone git@github.com:sshkarupa/rails-startup-kit.git

2. Rename the `rails-startup-kit` in your project's name (for example, in `cool_project`)

        $ mv rails-startup-kit cool_project


3. Change the default project's name in these files:

    ```
      - devops/base/dockerfile
      - devops/dev/dockerfile
      - devops/dev/docker-compose.yml
      - devops/prod/dockerfile
      - Makefile
    ```

    You need to change the project's name from `my_app` to `cool_project` and the namespace for docker images (`DOCKER_NAMESPACE` in `Makefile`) from `sshkarupa` to `what-ever-you-want`.

4. Go to your project's folder and remove the old `.git` folder

        $ cd cool_project && rm -rf .git

5. Rename `devops/dev/.sample.env` to `devops/dev/.env`

        cool_project$ mv devops/dev/{.sample.env,.env}

6. Build the base docker image:

        cool_project$ make build:base

7. Build the development docker image:

        coool_project$ make build:dev

8. Run a docker container and generate a new rails application

        cool_project$ make run

        /usr/src/cool_project# rails new . --skip-coffee --skip-turbolinks --skip-sprockets --webpack --database=postgresql -T -f
        /usr/src/cool_project# exit

9. Change owners for all folders and file which were generated inside the container (you will need to type your sudo password):

        cool_project$ make owner


10. Change your `config/database.yml` (default block) something like this:

```yaml
    default: &default
      adapter: postgresql
      encoding: unicode
      host: <%= ENV.fetch('DATABASE_HOST', 'db')%>
      username: <%= ENV.fetch('DATABASE_USERNAME', 'postgres')%>
      password:  <%= ENV.fetch('DATABASE_PASSWORD', '')%>
```

11. Create databases:

        cool_project$ make rake db:create

12. Run rails server:

        cool_project$ make start

You're all set!
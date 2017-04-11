# Compote

Compote is a wrapper for docker-compose. It extends compose in two ways.

Firstly, it adds additional fields in the config spec, main focus of those additions is to provide more flexibility with extending of services definitions.

Second, it adds abitility to specify custom commands as node's package.json "scripts" field do.


## Installation

    $ gem install compote


## Usage

You use `compote` as you do `docker-compose` as all commands are redirected to it.

Compote will search for `docker-compote.yml` file in current directory. You also can specify a path to a compote's config with env variable `COMPOTE_FILE`.

Here are additions that compote brings.

```yml
version: '2.1' # currently only version 2.1 supported

compote: # all additions live under compote key, here on top level and in a service definition

  # extends
  # allows to include definitions from other files
  # it can be a single string, an array of strings
  # it can also be a hash where keys are paths and values are objects with optional fields "except" and "only"
  # only
  # all paths resolved to a current compote config file
  extends:
    ../hello.yml: { only: [ 'volumes' ] }

  # env_file
  # can be a single string or array of strings
  # if files specified they must exist
  # if no file specified and there is .env file near config, it is used
  env_file: .hello_env

  # environment
  # can be a hash or an array of definitions (like the environment field in a service definition)
  environment:
    COMPOSE_PROJECT_NAME: hello

  # commands
  # commands specified here will be available for invocation by "compote command KEY [ARGS...]"
  # a resulted executed command will be "COMMAND [ARGS...]"
  # commands executed in environment combined from shell ones, env_file and environment options.
  # to list available commands call "compote commands"
  commands:
    hello: echo "hello"

services:

  hello:
    image: hello
    compote:

      # extends
      # same as extends in top compote settings, but with a name of a extended service after a colon
      # this is not the same as usual service extends, as it recursively merges everything and
      # does not care about ignoring some fields like docker-compose does
      # you can reproduce compose way using "except" or "only" options
      extends:
        - ../hello.yml:hello
        - ../hello.yml:world

      # volumes, networks
      # allow you to specify volumes and networks inside a service defintion
      # those fields will be merged in top level ones for docker-compose consumption
      # having those here simplifies extending of services
      volumes: {}
      networks: {}

      # commands
      # commands specified here will be available for invocation by "compote command SERVICE:KEY [ARGS...]"
      # a resulted executed command will be "compote run [OPTIONS] SERVICE [COMMAND] [ARGS]"
      # a command specified will be splited into two parts - run's options and a service command
      # a service command starts at first argument not starting with a dash
      commands:
        world: --rm bash # it will execute "docker-compose run --rm hello bash"
```


## TODO

- Tests with aruba.
- Interpolation of env variables in compote fields.
- Suggestions for misspelled commands.
- Add some power to `only` and `except` extend options for specifying nested paths.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vonagam/compote.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

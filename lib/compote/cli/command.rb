module Compote

  class CLI < Thor

    desc 'command', 'Run command specified in docker-compote config'

    def command ( key, *arguments )

      config = load_config

      commands = config.commands

      command = commands[ key ]

      service_name, command_name = key.include?( ':' ) ? key.split( ':' ) : [ nil, key ]

      raise UndefinedCommandError.new service_name: service_name, command_name: command_name, config: config unless command

      arguments = [ *Shellwords.split( command ), *arguments ]

      say "Running compote command \"#{ key }\":"

      if service_name

        run_arguments, command_arguments = split_arguments arguments

        arguments = [ 'run', *run_arguments, service_name, *command_arguments ]

        say Shellwords.join [ 'compote', *arguments ]

        run_compose *arguments

      else

        say Shellwords.join arguments

        environment = config.compose_environment

        exec environment, *arguments

      end

    rescue Error => error

      exit_with_error error

    end

    protected

    def split_arguments ( arguments )

      is_run_option = true

      run_arguments, command_arguments = arguments.partition do | argument |

        is_run_option &&= argument.match? /\A-/

        is_run_option

      end

      [ run_arguments, command_arguments ]

    end

  end

end

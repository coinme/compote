module Compote

  class CLI < Thor

    desc 'commands', 'List commands specified in docker-compote config'

    def commands

      config = load_config

      commands = config.commands

      if commands.empty?

        say 'No commands specified'

      else

        say commands.map { | key, command | "#{ key } -> #{ command }" }.join "\n"

      end

    rescue Error => error

      exit_with_error error

    end

  end

end

require 'compote'

require 'thor'

require 'shellwords'


module Compote

  class CLI < Thor

    require 'compote/cli/compose'

    require 'compote/cli/command'

    require 'compote/cli/commands'

    require 'compote/cli/env'

    require 'compote/cli/help'

    require 'compote/cli/version'

    protected

    def load_config

      path = ENV.fetch 'COMPOTE_FILE', './docker-compote.yml'

      config = Config.load_config path

      config

    end

    def run_compose ( command, *arguments )

      compote_config = load_config

      compose_environment = compote_config.compose_environment

      compose_file = compote_config.compose_file

      system compose_environment, 'docker-compose', '-f', compose_file.path, command, *arguments

      exit_status = $?.exitstatus

      compose_file.unlink

      exit exit_status

    rescue Error => error

      compose_file&.unlink

      exit_with_error error

    ensure

      compose_file&.unlink

    end

    def exit_with_error ( error )

      say error.message, :red

      exit 1

    end

  end

end

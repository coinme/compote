module Compote

  class CLI < Thor

    desc 'env', 'View the resulted compose environment'

    def env

      compote_config = load_config

      compose_environment = compote_config.compose_environment

      say YAML.dump compose_environment

    rescue Error => error

      exit_with_error error

    end

  end

end

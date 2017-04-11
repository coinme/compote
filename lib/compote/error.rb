module Compote

  class Error < StandardError

    attr_writer :message

  end


  class ConfigOpenError < Error

    def initialize ( error:, origin_config: )

      message = "Error loading config file: #{ error.message }"

      message += "\n" + "required from #{ origin_config.file_name }" if origin_config

      super message

    end

  end


  class ConfigFormatError < Error

    def initialize ( error:, data: )

      message = "Error loading config file: #{ error.message }" + "\n\n" + "#{ YAML.dump data }"

      super message

    end

  end


  class ConfigRecursionError < Error

    def initialize ( path:, origin_config:, configs: )

      message = "Error loading config file: Recursive loading of config files - #{ path }."

      message += "\n\n" + "Requiring trace:"

      message += "\n" + "#{ path }"

      requiring_path = origin_config.file_name

      loop do

        message += "\n" + "#{ requiring_path }"

        requiring_path = configs[ requiring_path ]

        break if requiring_path == path

      end

      super message

    end

  end


  class EnvFileOpenError < Error

    def initialize ( error:, config: )

      message = "Error loading env file: #{ error.message }"

      message += "\n" + "required from #{ config.file_name }"

      super message

    end

  end


  class EnvFileFormatError < Error

    def initialize ( error:, path:, config: )

      message = "Error loading env file: #{ error.message } - \"#{ path }\""

      message += "\n" + "required from #{ config.file_name }"

      super message

    end

  end


  class ServiceNotFoundError < Error

    attr_reader :service, :config


    def initialize ( service:, config: )

      @service = service

      @config = config

      message = "Error extending service: Service \"#{ service }\" not found in config \"#{ config.file_name }\"."

      super message

    end

  end


  class ProjectNameNotProvidedError < Error

    def initialize

      message = "Error running compote: Make sure that you provided env variable COMPOSE_PROJECT_NAME."

      super message

    end

  end


  class UndefinedCommandError < Error

    def initialize ( service_name:, command_name:, config: )

      message = "Error running compote command: Can't find command named \#{ command_name }\" for service \"#{ service_name }\" in config \"#{ config.file_name }\"."

      message += "\n" + "Seems that config doesn't have a service with such name." unless config.has_service_config? service_name

      super message

    end

  end

end

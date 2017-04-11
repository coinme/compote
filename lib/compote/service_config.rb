module Compote

  class ServiceConfig

    def initialize ( config, name, data )

      @config = config

      @name = name

      @data = apply_extends data


      @compote_settings = @data.fetch 'compote', {}

      @service_settings = @data.reject { | key, value | key == 'compote' }

    end

    def commands

      @compote_settings.fetch 'commands', {}

    end

    def compose_config

      compose_config = {}

      compose_config[ 'version' ] = @config.compose_version

      compose_config[ 'services' ] = @service_settings.empty? ? {} : { @name => @service_settings }

      compose_config[ 'volumes' ] = @compote_settings.fetch 'volumes', {}

      compose_config[ 'networks' ] = @compote_settings.fetch 'networks', {}

      compose_config

    end


    protected

    def data

      @data

    end

    def apply_extends ( initial_data )

      Schema.apply_extends initial_data do | key |

        key_info = key.split ':'

        key_info = [ '.', key_info[ 0 ] ] if key_info.size == 1

        config_path, service_name = key_info

        config = @config.load_config config_path

        service_config = config.get_service_config service_name

        data = service_config.data

        data

      end

    rescue ServiceNotFoundError => error

      error.message += "\n" + "If the service exists, check that its definition is higher than of service \"#{ @name }\"" if error.config == @config

      raise error

    end

  end

end

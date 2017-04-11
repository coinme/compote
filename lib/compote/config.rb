module Compote

  class Config

    def initialize ( file_name )

      data = YAML.load_file file_name

      data = Schema.normalize data

      @data = apply_extends data


      @file_name = file_name

      @directory_name = File.dirname file_name


      @compose_settings = @data.reject { | key, value | %w( compote services ).include? key }

      @compote_settings = @data.fetch 'compote', {}


      @services_configs = {}

      @data.fetch( 'services', {} ).each do | name, data |

        service_config = ServiceConfig.new self, name, data

        @services_configs[ name ] = service_config

      end

    end

    def file_name

      @file_name

    end

    def directory_name

      @directory_name

    end

    def compose_version

      @compose_settings.fetch 'version'

    end

    def compose_environment

      environment = {}


      environment_setting = @compote_settings.fetch 'environment', {}

      environment_setting.each do | key, value |

        environment[ key ] = ENV.fetch key, value

      end


      env_file_setting = @compote_settings.fetch 'env_file' do

        env_file_setting = []

        env_file_setting.push '.env' if File.exist? get_path '.env'

        env_file_setting

      end

      env_file_setting.each do | env_file_path |

        begin

          env_file_path = get_path env_file_path

          env_file_content = File.read env_file_path

          env_file_variables = Dotenv::Parser.call env_file_content

          env_file_variables.each do | key, value |

            environment[ key ] = ENV.fetch key, value

          end

        rescue Errno::ENOENT => error

          raise EnvFileOpenError.new error: error, config: self

        rescue Dotenv::FormatError => error

          raise EnvFileFormatError.new error: error, path: env_file_path, config: self

        end

      end


      raise ProjectNameNotProvidedError.new unless environment[ 'COMPOSE_PROJECT_NAME' ] || ENV[ 'COMPOSE_PROJECT_NAME' ]


      environment

    end

    def compose_file

      file = Tempfile.new 'docker-compose.yml'

      file.write YAML.dump compose_config

      file.close

      file

    end

    def commands

      commands = {}

      @compote_settings.fetch( 'commands', {} ).each do | name, command |

        commands[ name ] = command

      end

      @services_configs.each do | service_name, service_config |

        service_config.commands.each do | command_name, command |

          commands[ "#{ service_name }:#{ command_name }" ] = command

        end

      end

      commands

    end

    def compose_config

      compose_config = {}

      compose_config[ 'version' ] = @compose_settings.fetch 'version'

      compose_config[ 'volumes' ] = @compose_settings.fetch 'volumes', {}

      compose_config[ 'networks' ] = @compose_settings.fetch 'networks', {}


      compose_config[ 'services' ] = {}

      @services_configs.each do | name, service_config |

        service_compose_config = service_config.compose_config

        compose_config[ 'services' ].merge! service_compose_config.fetch( 'services', {} )

        compose_config[ 'volumes' ].merge! service_compose_config.fetch( 'volumes', {} )

        compose_config[ 'networks' ].merge! service_compose_config.fetch( 'networks', {} )

      end


      compose_config

    end

    def get_service_config ( name )

      @services_configs.fetch name

    rescue KeyError => error

      raise ServiceNotFoundError.new service: name, config: self

    end

    def has_service_config? ( name )

      @services_configs.has_key? name

    end

    def load_config ( path )

      Config.load_config path, self

    end

    def get_path ( path )

      Config.get_path path, self

    end


    @@configs = {}

    def self.load_config ( path, origin_config = nil )

      path = get_path path, origin_config

      return origin_config if path == origin_config&.directory_name

      config = @@configs[ path ]

      raise ConfigRecursionError path: path, origin_config: origin_config, configs: configs if config.is_a? String

      return config if config

      @@configs[ path ] = origin_config&.file_name || ''

      config = Config.new path

      @@configs[ path ] = config

      config

    rescue Errno::ENOENT => error

      raise ConfigOpenError.new error: error, origin_config: origin_config

    end

    def self.get_path ( path, origin_config = nil )

      path = File.absolute_path path, origin_config&.directory_name

      path = Pathname.new( path ).cleanpath.to_path

      path

    end


    protected

    def data

      @data

    end

    def apply_extends ( initial_data )

      Schema.apply_extends initial_data do | path |

        config = load_config path

        data = config.data

        data

      end

    end

  end

end

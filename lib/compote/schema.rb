module Compote

  module Schema

    resolve_relative_path = {

      String => proc { | value, config |

        value = config.get_path value if value.start_with? '.'

        value

      },

    }

    wrap_string_in_array = {

      String => proc { | value |

        [ value ]

      },

    }

    options_array_to_hash = {

      Array => proc { | value |

        value.map do | value |

          [ value, {} ]

        end.to_h

      },

    }

    variables_array_to_hash = {

      Array => proc { | value |

        value.map do | value |

          result = value.split '=', 2

          result += [ nil ] if result.size == 1

          result

        end.to_h

      },

    }

    labels_array_to_hash = {

      Array => proc { | value |

        value.map do | value |

          result = value.split '=', 2

          result += [ '' ] if result.size == 1

          result

        end.to_h

      },

    }

    compote_extends_to_hash = {

      String => proc { | value | { value => {} } },

      Array => options_array_to_hash[ Array ],

      Hash => proc { | value | value.map { | key, value | [ key, value || {} ] }.to_h },

      '*' => {

        'only' => wrap_string_in_array,

        'except' => wrap_string_in_array,

      },

    }

    env_files_mapping = {

      String => wrap_string_in_array[ String ],

      '*' => resolve_relative_path,

    },


    MAPPINGS = {

      'compote' => {

        'extends' => compote_extends_to_hash,

        'env_file' => env_files_mapping,

        'environment' => variables_array_to_hash,

      },

      'volumes' => {

        '*' => {

          'labels' => labels_array_to_hash,

        },

      },

      'networks' => {

        '*' => {

          'labels' => labels_array_to_hash,

        },

      },

      'services' => {

        '*' => {

          'build' => {

            String => proc { | value | { 'context' => value } },

            'args' => variables_array_to_hash,

          },

          'depends_on' => options_array_to_hash,

          'dns' => wrap_string_in_array,

          'dns_search' => wrap_string_in_array,

          'tmpfs' => wrap_string_in_array,

          'env_file' => env_files_mapping,

          'environment' => variables_array_to_hash,

          'labels' => labels_array_to_hash,

          'sysctls' => variables_array_to_hash,

          'volumes' => {

            '*' => {

              String => proc { | value, config |

                if value.start_with? '.'

                  values = value.split ':'

                  values[ 0 ] = config.get_path values[ 0 ]

                  value = values.join ':'

                end

                value

              },

            },

          },

          'compote' => {

            'extends' => compote_extends_to_hash,

            'volumes' => {

              '*' => {

                'labels' => labels_array_to_hash,

              },

            },

            'networks' => {

              '*' => {

                'labels' => labels_array_to_hash,

              },

            },

          },

        },

      },

    }


    def self.validate! ( data )

      scheme = Pathname.new( __FILE__ ).join( '../schema.json' ).to_path

      JSON::Validator.validate! scheme, data

    rescue JSON::Schema::ValidationError => error

      raise ConfigFormatError.new error: error, data: data

    end

    def self.normalize ( config, value, mappings = MAPPINGS )

      validate! value if mappings == MAPPINGS


      value = value.clone


      class_mappings = mappings.select { | key, value | key.is_a? Class }

      unless class_mappings.empty?

        class_mapping = class_mappings[ value.class ]

        value = class_mapping.call value, config if class_mapping

      end


      paths_mappings = mappings.select { | key, value | key.is_a? String }

      unless paths_mappings.empty? || ! value.is_a?( Enumerable ) || value.empty?

        if paths_mappings.keys == [ '*' ]

          path_mappings = paths_mappings[ '*' ]

          if value.is_a? Hash

            value = value.map do | key, value |

              [ key, normalize( config, value, path_mappings ) ]

            end.to_h

          end

          if value.is_a? Array

            value = value.map do | value |

              normalize config, value, path_mappings

            end

          end

        elsif value.is_a? Hash

          value = value.map do | key, value |

            path_mappings = paths_mappings[ key ]

            if path_mappings

              [ key, normalize( config, value, path_mappings ) ]

            else

              [ key, value ]

            end

          end.to_h

        end

      end


      value

    end

    def self.apply_extends ( initial_data, &get_data )

      extends = initial_data.dig 'compote', 'extends'

      return initial_data.clone unless extends

      extending_datas = extends.map do | key, options |

        data = get_data.call key

        data = data.select { | key, value | options[ 'only' ].include? key } if options[ 'only' ]

        data = data.reject { | key, value | options[ 'except' ].include? key } if options[ 'except' ]

        data

      end

      extending_datas += [ initial_data ]

      resulted_data = merge extending_datas

      resulted_data

    end

    def self.merge ( datas )

      result = {}

      datas.each do | data |

        data.keys.each do | key |

          values = [ result[ key ], data[ key ] ]

          result[ key ] = begin

            if values.all? { | value | value.is_a? Hash }

              merge values

            elsif values.all? { | value | value.is_a? Array } && ! %w( command entrypoint ).include?( key )

              values.first + values.last

            else

              values.last.clone

            end

          end

        end

      end

      result

    end

  end

end

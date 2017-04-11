module Compote

  class CLI < Thor

    COMPOSE_COMMANDS = %w()

    COMPOTE_COMMANDS = %w( env help version )


    compose_help = `docker-compose --help`

    compose_help = compose_help.split "\n"

    compose_help = compose_help.slice ( compose_help.index( "Commands:" ) + 1 )..-1

    compose_help.each do | command_info |

      command, description = command_info.strip.split( /\s+/, 2 )

      next if COMPOTE_COMMANDS.include? command

      COMPOSE_COMMANDS.push command


      desc command, description

      define_method "compose_#{ command }" do | *arguments |

        next exec 'docker-compose', command, *arguments if %w(-h --help).include? arguments[ 0 ]

        run_compose command, *arguments

      end

      map command => "compose_#{ command }"

    end

  end

end

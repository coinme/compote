module Compote

  class CLI < Thor

    desc 'help', 'Get help on a command'

    def help ( *arguments )

      if COMPOSE_COMMANDS.include? arguments.first

        exec 'docker-compose', 'help', *arguments

      else

        super *arguments

      end

    end

  end

end

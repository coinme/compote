module Compote

  class CLI < Thor

    desc 'version', 'Show version information'

    method_option :short, type: :boolean, desc: "Shows only Compote's and Compose's version numbers."

    def version

      compote_version = "compote version: #{ Compote::VERSION }"

      compose_version = if options[ :short ]

        "docker-compose version: #{ `docker-compose version --short` }"

      else

        `docker-compose version`

      end

      say compote_version

      say compose_version

    end

  end

end

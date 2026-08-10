require_relative "../target"

class Styr
  class Backend
    class HerokuBackend
      class Target < Styr::Target
        def display
          config["app"]
        end
      end

      def initialize(config)
        @config = config
      end

      def execute(command)
        system("heroku", "run", command, "--app", @config['app'])
      end

      def to_s
        "Heroku"
      end
    end
  end
end

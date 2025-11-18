class Styr
  class Backend
    class HerokuBackend
      def initialize(config)
        @config = config
      end

      def execute(command)
        runner = TTY::Command.new
        runner.run(
          "heroku run",
          command,
          "--app",
          @config['app'],
          :pty => true
        )
      end

      def to_s
        "Heroku"
      end
    end
  end
end

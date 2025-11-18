class Styr
  class Backend
    class SSHBackend
      def initialize(config)
        @config = config
      end

      def execute(command)
        puts "Executing '#{command}' via #{self} with #{@config['app']}"
      end

      def to_s
        "SSH"
      end
    end

    class << self
      def from_config(config)
        backend_type = config.fetch("backend")
        backend_class =
          case backend_type.downcase
          when "heroku"
            HerokuBackend
          when "ssh"
            SSHBackend
          else
            raise "Unknown backend type: #{backend_type}"
          end
        backend_class.new(config)
      end
    end
  end
end

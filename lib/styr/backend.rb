# frozen_string_literal: true

class Styr
  class Backend
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

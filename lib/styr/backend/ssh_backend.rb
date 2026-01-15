# frozen_string_literal: true

require_relative "../target"

class Styr
  class Backend
    class SSHBackend
      # A Target reached via SSH
      class Target < Styr::Target
        def display
          [
            config.values_at("user", "host").compact.join("@"),
            config["path"]
        ].join(":")
        end
      end

      def initialize(config)
        @config = config
      end

      def execute(command)
        runner = TTY::Command.new

        # Build SSH connection string
        ssh_target = @config["host"]
        ssh_target = "#{@config['user']}@#{ssh_target}" if @config["user"]

        # Build remote command with optional path change
        remote_command = if @config["path"]
          "cd #{@config['path']} && #{command}"
        else
          command
        end

        runner.run(
          "ssh",
          ssh_target,
          remote_command,
          :pty => true
        )
      end

      def to_s
        "SSH"
      end
    end
  end
end

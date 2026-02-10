# frozen_string_literal: true

require "optparse"

require_relative "../config"
require_relative "task"

class Styr
  class CLI
    class ConfigTask < Task
      class << self
        def description
          "Show the currently used configuration"
        end

        def help
          [
            description,
            "",
            "Usage: #{$0} #{name}",
          ].join("\n")
        end

        def name
          "config"
        end
      end

      def process(args, global_options = {})
        self.params = {
          :help => global_options[:help],
        }

        perform
      end

      private

      def perform
        puts Styr::Config::CONFIG_PATH

        config = Styr::Config.load
        puts config unless config.empty?
      end
    end
  end
end

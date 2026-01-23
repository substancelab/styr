# frozen_string_literal: true

require "optparse"

require_relative "../config"
require_relative "task"

class Styr
  class CLI
    class TargetsTask < Task
      class << self
        def description
          "List configured targets"
        end

        def help
          [
            description,
            "",
            "Usage: #{$0} targets",
          ].join("\n")
        end

        def name
          "targets"
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
        targets = Styr.instance.targets.map do |target|
          [target.name, target.backend, target.display]
        end

        if targets.any?
          table = TTY::Table.new(
            :header => ["Name", "Backend", "Details"],
            :rows => targets
          )

          puts table.render(:unicode, padding: [0,1])
        else
          puts "No targets configured."
        end
      end
    end
  end
end

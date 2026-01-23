# frozen_string_literal: true

require "optparse"

require_relative "../config"
require_relative "task"

class Styr
  class CLI
    class TargetsTask < Task
      NAME = "targets"

      def description
        "List known targets"
      end

      def process(args, global_options = {})
        self.params = {
          :help => global_options[:help],
        }

        exit_with_help if params[:help]

        perform
      end

      private

      def exit_with_help
        puts description
        puts
        puts "Usage: styr targets"
        exit 0
      end

      def perform
        targets = Styr.instance.targets.map do |target|
          [target.name, target.backend, target.display]
        end

        table = TTY::Table.new(
          :header => ["Name", "Backend", "Details"],
          :rows => targets
        )

        puts table.render(:ascii)
      end
    end
  end
end

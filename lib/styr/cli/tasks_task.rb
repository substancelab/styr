# frozen_string_literal: true

require "optparse"

require_relative "../config"
require_relative "task"

class Styr
  class CLI
    class TasksTask < Task
      class << self
        def description
          "List available tasks"
        end

        def help
          [
            description,
            "",
            "Usage: #{$0} tasks",
          ].join("\n")
        end

        def name
          "tasks"
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
        task_helps = Styr.instance.tasks.map { |task| [task.name, task.description] }
        longest_name_length = task_helps.map { |name, _| name.length }.max || 0

        task_helps.each do |name, description|
          puts("   %-#{longest_name_length}s   %s" % [name, description])
        end
      end
    end
  end
end

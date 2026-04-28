# frozen_string_literal: true

require_relative "run_task"
require_relative "task"

class Styr
  class CLI
    class ConfigurableTask < Task
      class << self
        def for(task_name, command)
          Class.new(self) do
            @task_name = task_name
            @command = command

            class << self
              attr_reader :command

              def name
                @task_name
              end

              def description
                "Run \"#{@command}\" on the target"
              end

              def help
                [
                  description,
                  "",
                  "Usage: #{$0} --target TARGET #{name} [ARGS]",
                  "",
                  "Options:",
                  "  TARGET    Target to run the command on",
                  "  ARGS      Additional arguments appended to the configured command",
                ].join("\n")
              end
            end
          end
        end
      end

      def process(args, global_options = {})
        Styr::CLI::RunTask.new.process([self.class.command, *args], global_options)
      end
    end
  end
end

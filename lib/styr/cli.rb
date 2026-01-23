# frozen_string_literal: true

require "optparse"

require_relative "config"

require_relative "cli/run_task"
require_relative "cli/targets_task"

class Styr
  class CLI
    class << self
      def process(input_command, args = [])
        global_parser = OptionParser.new do |opts|
          opts.banner = "styr task [options] command"
          opts.on("--help", "Show helpful information")
          opts.on("--target TARGET", "Target to perform the task on")
        end

        global_options = {}
        global_parser.order!(:into => global_options)

        task_name = ARGV[0].to_s.downcase
        task = tasks.find do |task_class|
          task_class::NAME == task_name
        end

        if task
          task.new.process(ARGV[1..], global_options)
        else
          puts Styr::CLI::Task.new.description
          exit 1
        end
      end

      def tasks
        [
          RunTask,
          TargetsTask
        ]
      end
    end
  end
end

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
          opts.banner = "styr [options] task [task options]"
          opts.on("--help", "Show helpful information")
          opts.on("--target TARGET", "Target to perform the task on")
        end

        global_options = {}
        global_parser.order!(:into => global_options)

        task_name = ARGV[0].to_s.downcase

        if global_options[:help] || task_name.nil? || task_name == ""
          puts global_parser
          exit 0
        end

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

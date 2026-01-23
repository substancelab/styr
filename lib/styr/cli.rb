# frozen_string_literal: true

require "optparse"

require_relative "config"

class Styr
  class CLI
    class << self
      def process(input_command, args = [])
        global_parser = OptionParser.new do |opts|
          opts.banner = "styr [options] [--target] task [task options]"
          opts.on("--help", "Show helpful information")
          opts.on("--target TARGET", "Target to perform the task on")
        end

        global_options = {}
        global_parser.order!(:into => global_options)

        task_name = ARGV[0].to_s.downcase
        task = tasks.find do |task_class|
          task_class.name == task_name
        end

        if global_options[:help]
          if task
            output_help_for_task(task)
          else
            output_help(global_parser)
          end
          exit 0
        end

        if task
          task.new.process(ARGV[1..], global_options)
        else
          puts "Unknown task: #{task_name}"
          puts
          puts "Expected one of #{tasks.map(&:name).join(', ')}"
          exit 1
        end
      end

      private

      def output_help(global_parser)
        task_helps = tasks.map { |task| [task.name, task.description] }
        longest_name_length = task_helps.map { |name, _| name.length }.max || 0

        puts global_parser
        puts
        puts "Available tasks:"
        Styr::CLI::TasksTask.new.process([], {})
      end

      def output_help_for_task(task)
        puts task.help
      end

      def tasks
        Styr.instance.tasks
      end
    end
  end
end

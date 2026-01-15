# frozen_string_literal: true

require "optparse"

require_relative "config"

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

    class Task < CLI
      attr_accessor :params

      def description
        "TODO: Generic help"
      end
    end

    class RunTask < Task
      NAME = "run"

      def process(args, global_options = {})
        self.params = {
          :command => args.join(" "),
          :help => global_options[:help],
          :target => global_options[:target],
        }

        exit_with_help if params[:help]

        validate_targets(params[:target])

        perform
      end

      private

      def exit_with_help
        puts "Usage: styr run --target TARGET command to run on the target"
        exit 0
      end

      def perform
        targets.each do |target_name|
          target = Styr.instance.targets.find { |t| t.name.to_s == target_name.to_s }
          backend = target.backend
          backend.execute(params[:command])
        end
      end

      def targets
        Array(params[:target])
      end

      def validate_inputs
        return if params.errors.empty?

        puts params.errors.summary
        exit 1
      end

      def validate_targets(target_names)
        target_names = Array(target_names)
        targets = Config.load["targets"] || {}
        known_targets = targets.keys.map(&:to_s)

        unknown_targets = target_names.reject do |target_name|
          known_targets.include?(target_name)
        end
        return if target_names.any? && unknown_targets.empty?

        puts "Unknown targets: #{unknown_targets.join(', ')}. Expected one of: #{known_targets.join(', ')}"
        exit 1
      end
    end

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

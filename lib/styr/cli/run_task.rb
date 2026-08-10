# frozen_string_literal: true

require "optparse"

require_relative "../config"
require_relative "task"

class Styr
  class CLI
    class RunTask < Task
      class << self
        def description
          "Run a command on a target"
        end

        def help
          [
            description,
            "",
            "Usage: #{$0} --target TARGET run COMMAND",
            "       #{$0} --target-all run COMMAND",
            "",
            "Options:",
            "  TARGET    Target(s) to run the command on, comma-separated",
            "  COMMAND   Command to run on the target",
            "",
            "Example:",
            "  #{$0} --target production run 'ls -la'",
            "  #{$0} --target-all run 'ls -la'",
          ].join("\n")
        end

        def name
          "run"
        end
      end

      def process(args, global_options = {})
        validate_target_options(global_options)

        self.params = {
          :command => args.join(" "),
          :help => global_options[:help],
          :target => if global_options[:"target-all"]
            all_targets
          else
            split_targets(global_options[:target])
          end,
        }

        validate_targets(params[:target])

        perform
      end

      private

      def all_targets
        known_targets = (Config.load["targets"] || {}).keys.map(&:to_s)

        if known_targets.empty?
          puts "No targets configured."
          exit 1
        end

        known_targets
      end

      def perform
        multiple_targets = targets.length > 1
        success = true

        targets.each do |target_name|
          target = Styr.instance.targets.find { |t| t.name.to_s == target_name.to_s }
          puts "==> #{target_name}" if multiple_targets
          success = false unless target.backend.execute(params[:command])
        end

        exit 1 unless success
      end

      def targets
        Array(params[:target])
      end

      def split_targets(target)
        Array(target).flat_map { |t| t.to_s.split(",") }.map(&:strip).reject(&:empty?)
      end

      def validate_inputs
        return if params.errors.empty?

        puts params.errors.summary
        exit 1
      end

      def validate_target_options(global_options)
        return unless global_options[:"target-all"] && global_options[:target]

        puts "Cannot use --target and --target-all together"
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
  end
end

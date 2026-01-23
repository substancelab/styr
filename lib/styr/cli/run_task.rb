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

        def name
          "run"
        end
      end

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
  end
end

# frozen_string_literal: true

require "singleton"

require_relative "styr/backend"
require_relative "styr/cli"
require_relative "styr/cli/config_task"
require_relative "styr/cli/configurable_task"
require_relative "styr/cli/run_task"
require_relative "styr/cli/targets_task"
require_relative "styr/cli/tasks_task"

class Styr
  include Singleton

  def process_input_command(input_command, args = [])
    Styr::CLI.process(input_command, args)
  end

  # Returns all configured targets
  #
  # @return [Array<Styr::Target>]
  def targets
    return @targets if @targets

    config = Config.load
    targets_config = config["targets"] || {}
    @targets = targets_config.map do |target_name, target_config|
      backend = Styr::Backend.from_config(target_config)
      backend.class::Target.new(target_name, target_config)
    end
  end

  def tasks
    builtin_tasks + custom_tasks
  end

  private

  def builtin_tasks
    [
      Styr::CLI::ConfigTask,
      Styr::CLI::RunTask,
      Styr::CLI::TargetsTask,
      Styr::CLI::TasksTask,
    ]
  end

  def custom_tasks
    tasks_config = Config.load["tasks"] || {}
    tasks_config.map do |task_name, task_config|
      command = task_config["command"]
      unless command.is_a?(String) && !command.strip.empty?
        warn "styr: task '#{task_name}' has no valid command configured and will be skipped"
        next
      end
      Styr::CLI::ConfigurableTask.for(task_name, command)
    end.compact
  end
end

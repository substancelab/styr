# frozen_string_literal: true

require "singleton"

require_relative "styr/cli"

class Styr
  include Singleton

  def process_input_command(input_command, args = [])
    Styr::CLI.process(input_command, args)
  end

  def targets
    return @targets if @targets

    config = Config.load
    targets_config = config["targets"] || {}
    @targets = targets_config.map do |target_name, target_config|
      Target.new(target_name, target_config)
    end
  end
end

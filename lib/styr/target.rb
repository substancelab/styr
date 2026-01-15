# frozen_string_literal: true

class Styr
  # A deployment target that Styr can remote control
  class Target
    attr_reader :name, :config

    def initialize(name, config)
      @name = name
      @config = config
    end

    def backend
      @backend ||= Styr::Backend.from_config(@config)
    end

    # Returns details about the target, e.g. app name for Heroku, host for SSH,
    # intended to human readable display in the target list.
    def display
    end
  end
end

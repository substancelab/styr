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
  end
end

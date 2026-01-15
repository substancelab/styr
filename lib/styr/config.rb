# frozen_string_literal: true

require "pathname"

require_relative "backend"
require_relative "backend/heroku_backend"
require_relative "backend/ssh_backend"
require_relative "target"

class Styr
  class Config
    CONFIG_PATH = Pathname.new(Dir.pwd).join(".config/styr.toml")

    def self.load
      @config ||= if File.exist?(CONFIG_PATH) # rubocop:disable Naming/MemoizedInstanceVariableName
        TomlRB.load_file(CONFIG_PATH)
      else
        {}
      end
    end
  end
end

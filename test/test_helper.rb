# frozen_string_literal: true

require "bundler/setup"
require "minitest/autorun"
require "minitest/mock"
require "toml-rb"
require "tty-table"

require_relative "../lib/styr"

module ResetsStyrState
  def setup
    super
    Styr::Config.instance_variable_set(:@config, nil)
    Styr.instance.instance_variable_set(:@targets, nil)
  end
end

Minitest::Test.include(ResetsStyrState)

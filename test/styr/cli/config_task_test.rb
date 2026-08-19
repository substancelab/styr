# frozen_string_literal: true

require_relative "../../test_helper"

class ConfigTaskTest < Minitest::Test
  def test_process_prints_config_path
    Styr::Config.stub(:load, {}) do
      out, = capture_io { Styr::CLI::ConfigTask.new.process([], {}) }
      assert_match(Styr::Config::CONFIG_PATH.to_s, out)
    end
  end

  def test_process_prints_config_contents_when_present
    Styr::Config.stub(:load, {"targets" => {}}) do
      out, = capture_io { Styr::CLI::ConfigTask.new.process([], {}) }
      assert_match(/targets/, out)
    end
  end
end

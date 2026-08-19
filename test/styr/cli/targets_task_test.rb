# frozen_string_literal: true

require_relative "../../test_helper"

class TargetsTaskTest < Minitest::Test
  def test_process_prints_no_targets_message_when_empty
    Styr::Config.stub(:load, {}) do
      out, = capture_io { Styr::CLI::TargetsTask.new.process([], {}) }
      assert_match(/No targets configured\./, out)
    end
  end

  def test_process_prints_table_of_targets
    config = { "targets" => { "production" => { "backend" => "heroku", "app" => "myapp" } } }

    Styr::Config.stub(:load, config) do
      out, = TTY::Screen.stub(:width, 80) { capture_io { Styr::CLI::TargetsTask.new.process([], {}) } }

      assert_match(/production/, out)
      assert_match(/Heroku/, out)
      assert_match(/myapp/, out)
    end
  end
end

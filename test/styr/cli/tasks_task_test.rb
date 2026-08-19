# frozen_string_literal: true

require_relative "../../test_helper"

class TasksTaskTest < Minitest::Test
  def test_process_lists_task_names_and_descriptions
    Styr::Config.stub(:load, {}) do
      out, = capture_io { Styr::CLI::TasksTask.new.process([], {}) }

      assert_match(/run\s+Run a command on a target/, out)
      assert_match(/targets\s+List configured targets/, out)
    end
  end
end

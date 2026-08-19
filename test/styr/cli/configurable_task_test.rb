# frozen_string_literal: true

require_relative "../../test_helper"

class ConfigurableTaskTest < Minitest::Test
  def test_for_builds_a_task_class_with_name_and_command
    task_class = Styr::CLI::ConfigurableTask.for("deploy", "git push heroku main")

    assert_equal("deploy", task_class.name)
    assert_equal("git push heroku main", task_class.command)
    assert_equal("Run \"git push heroku main\" on the target", task_class.description)
  end

  def test_process_delegates_to_run_task_with_configured_command_and_extra_args
    task_class = Styr::CLI::ConfigurableTask.for("deploy", "git push heroku main")
    recorded = nil
    run_task = Minitest::Mock.new
    run_task.expect(:process, nil) do |args, global_options|
      recorded = [args, global_options]
      true
    end

    Styr::CLI::RunTask.stub(:new, run_task) do
      task_class.new.process(["--force"], target: "production")
    end

    assert_equal([["git push heroku main", "--force"], {target: "production"}], recorded)
    run_task.verify
  end
end

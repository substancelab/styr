# frozen_string_literal: true

require_relative "../../test_helper"

class RunTaskTest < Minitest::Test
  def config
    {
      "targets" => {
        "production" => {"backend" => "heroku", "app" => "myapp"},
        "staging" => {"backend" => "heroku", "app" => "myapp-staging"}
      }
    }
  end

  def test_process_exits_when_target_and_target_all_given
    task = Styr::CLI::RunTask.new

    out, = capture_io do
      assert_raises(SystemExit) do
        task.process(["ls"], target: "production", "target-all": true)
      end
    end

    assert_match(/Cannot use --target and --target-all together/, out)
  end

  def test_process_splits_comma_separated_targets
    Styr::Config.stub(:load, config) do
      task = Styr::CLI::RunTask.new
      executed = []
      Styr.instance.targets.each do |target|
        target.backend.define_singleton_method(:execute) { |cmd|
          executed << [target.name, cmd]
          true
        }
      end

      capture_io { task.process(["ls", "-la"], target: "production, staging") }

      assert_equal([["production", "ls -la"], ["staging", "ls -la"]], executed)
    end
  end

  def test_process_target_all_runs_on_every_configured_target
    Styr::Config.stub(:load, config) do
      task = Styr::CLI::RunTask.new
      executed = []
      Styr.instance.targets.each do |target|
        target.backend.define_singleton_method(:execute) { |cmd|
          executed << target.name
          true
        }
      end

      capture_io { task.process(["ls"], "target-all": true) }

      assert_equal(%w[production staging], executed)
    end
  end

  def test_process_exits_when_no_targets_configured_for_target_all
    Styr::Config.stub(:load, {}) do
      task = Styr::CLI::RunTask.new

      out, = capture_io do
        assert_raises(SystemExit) { task.process(["ls"], "target-all": true) }
      end

      assert_match(/No targets configured\./, out)
    end
  end

  def test_process_exits_on_unknown_target
    Styr::Config.stub(:load, config) do
      task = Styr::CLI::RunTask.new

      out, = capture_io do
        assert_raises(SystemExit) { task.process(["ls"], target: "bogus") }
      end

      assert_match(/Unknown targets: bogus/, out)
    end
  end

  def test_process_exits_when_no_target_specified
    Styr::Config.stub(:load, config) do
      task = Styr::CLI::RunTask.new

      assert_raises(SystemExit) { capture_io { task.process(["ls"], {}) } }
    end
  end

  def test_process_exits_when_any_target_execution_fails
    Styr::Config.stub(:load, config) do
      task = Styr::CLI::RunTask.new
      Styr.instance.targets.each do |target|
        target.backend.define_singleton_method(:execute) { |_cmd| !(target.name == "staging") }
      end

      capture_io { assert_raises(SystemExit) { task.process(["ls"], "target-all": true) } }
    end
  end

  def test_process_prints_target_header_only_with_multiple_targets
    Styr::Config.stub(:load, config) do
      task = Styr::CLI::RunTask.new
      Styr.instance.targets.each { |t| t.backend.define_singleton_method(:execute) { |_cmd| true } }

      out, = capture_io { task.process(["ls"], target: "production") }
      refute_match(/==>/, out)

      out, = capture_io { task.process(["ls"], "target-all": true) }
      assert_match(/==> production/, out)
      assert_match(/==> staging/, out)
    end
  end
end

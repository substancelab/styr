# frozen_string_literal: true

require_relative "../test_helper"

class CLITest < Minitest::Test
  # Styr::CLI.process reads its task name and args from the real ARGV rather
  # than the arguments passed to it, so tests drive it through ARGV directly.
  def with_argv(*args)
    original = ARGV.dup
    ARGV.replace(args)
    yield
  ensure
    ARGV.replace(original)
  end

  def test_process_dispatches_known_task
    called_with = nil
    task_instance = Minitest::Mock.new
    task_instance.expect(:process, nil) do |args, global_options|
      called_with = [args, global_options]
      true
    end

    Styr::CLI::TargetsTask.stub(:new, task_instance) do
      with_argv("targets") { Styr::CLI.process("targets", []) }
    end

    assert_equal([[], {}], called_with)
    task_instance.verify
  end

  def test_process_reports_unknown_task
    out, = with_argv("bogus") do
      capture_io { assert_raises(SystemExit) { Styr::CLI.process("bogus", []) } }
    end

    assert_match(/Unknown task: bogus/, out)
  end

  def test_process_shows_help_when_no_task_given
    out, = with_argv do
      capture_io { assert_raises(SystemExit) { Styr::CLI.process("", []) } }
    end

    assert_match(/Available tasks:/, out)
  end

  def test_process_shows_task_help_with_help_flag
    out, = with_argv("--help", "targets") do
      capture_io { assert_raises(SystemExit) { Styr::CLI.process("targets", []) } }
    end

    assert_match(/List configured targets/, out)
  end
end

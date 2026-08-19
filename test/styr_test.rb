# frozen_string_literal: true

require_relative "test_helper"

class StyrTest < Minitest::Test
  def test_targets_builds_targets_from_config
    config = {
      "targets" => {
        "production" => {"backend" => "heroku", "app" => "myapp"},
        "staging" => {"backend" => "ssh", "host" => "staging.example.com"}
      }
    }

    Styr::Config.stub(:load, config) do
      targets = Styr.instance.targets

      assert_equal(2, targets.length)
      assert_equal(%w[production staging], targets.map(&:name))
      assert_instance_of(Styr::Backend::HerokuBackend::Target, targets[0])
      assert_instance_of(Styr::Backend::SSHBackend::Target, targets[1])
    end
  end

  def test_targets_returns_empty_array_when_none_configured
    Styr::Config.stub(:load, {}) do
      assert_equal([], Styr.instance.targets)
    end
  end

  def test_targets_is_memoized
    Styr::Config.stub(:load, {"targets" => {"a" => {"backend" => "heroku", "app" => "x"}}}) do
      first = Styr.instance.targets
      assert_same(first, Styr.instance.targets)
    end
  end

  def test_tasks_includes_builtin_tasks
    Styr::Config.stub(:load, {}) do
      task_names = Styr.instance.tasks.map(&:name)

      assert_includes(task_names, "run")
      assert_includes(task_names, "targets")
      assert_includes(task_names, "tasks")
      assert_includes(task_names, "config")
    end
  end

  def test_tasks_includes_valid_custom_tasks
    config = {"tasks" => {"deploy" => {"command" => "git push heroku main"}}}

    Styr::Config.stub(:load, config) do
      custom = Styr.instance.tasks.find { |t| t.name == "deploy" }

      refute_nil(custom)
      assert_equal("deploy", custom.name)
      assert_equal("git push heroku main", custom.command)
    end
  end

  def test_tasks_skips_custom_task_without_command
    config = {"tasks" => {"broken" => {}}}

    _out, err = capture_io do
      Styr::Config.stub(:load, config) do
        assert_nil(Styr.instance.tasks.find { |t| t.name == "broken" })
      end
    end

    assert_match(/no valid command configured/, err)
  end

  def test_tasks_skips_custom_task_conflicting_with_builtin
    config = {"tasks" => {"run" => {"command" => "echo hi"}}}

    _out, err = capture_io do
      Styr::Config.stub(:load, config) do
        tasks = Styr.instance.tasks
        assert_equal(1, tasks.count { |t| t.name == "run" })
        assert_same(Styr::CLI::RunTask, tasks.find { |t| t.name == "run" })
      end
    end

    assert_match(/conflicts with an existing task/, err)
  end
end

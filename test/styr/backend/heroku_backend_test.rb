# frozen_string_literal: true

require_relative "../../test_helper"

class HerokuBackendTest < Minitest::Test
  def setup
    super
    @config = {"backend" => "heroku", "app" => "myapp"}
    @backend = Styr::Backend::HerokuBackend.new(@config)
  end

  def test_execute_runs_heroku_run_with_app
    recorded = nil
    @backend.define_singleton_method(:system) do |*args|
      recorded = args
      true
    end

    @backend.execute("rails console")

    assert_equal(["heroku", "run", "rails console", "--app", "myapp"], recorded)
  end

  def test_execute_returns_system_result
    @backend.define_singleton_method(:system) { |*_args| false }

    refute(@backend.execute("boom"))
  end

  def test_to_s
    assert_equal("Heroku", @backend.to_s)
  end

  def test_target_display_returns_app_name
    target = Styr::Backend::HerokuBackend::Target.new("production", @config)
    assert_equal("myapp", target.display)
  end
end

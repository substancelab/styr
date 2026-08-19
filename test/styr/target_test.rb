# frozen_string_literal: true

require_relative "../test_helper"

class TargetTest < Minitest::Test
  def test_stores_name_and_config
    target = Styr::Target.new("production", "backend" => "heroku", "app" => "myapp")

    assert_equal("production", target.name)
    assert_equal({"backend" => "heroku", "app" => "myapp"}, target.config)
  end

  def test_backend_is_built_lazily_from_config
    target = Styr::Target.new("production", "backend" => "heroku", "app" => "myapp")

    assert_instance_of(Styr::Backend::HerokuBackend, target.backend)
  end

  def test_backend_is_memoized
    target = Styr::Target.new("production", "backend" => "heroku", "app" => "myapp")

    assert_same(target.backend, target.backend)
  end

  def test_display_defaults_to_nil
    target = Styr::Target.new("production", "backend" => "heroku", "app" => "myapp")

    assert_nil(target.display)
  end
end

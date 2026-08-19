# frozen_string_literal: true

require_relative "../test_helper"

class BackendTest < Minitest::Test
  def test_from_config_returns_heroku_backend
    backend = Styr::Backend.from_config("backend" => "heroku", "app" => "myapp")
    assert_instance_of(Styr::Backend::HerokuBackend, backend)
  end

  def test_from_config_returns_ssh_backend
    backend = Styr::Backend.from_config("backend" => "ssh", "host" => "example.com")
    assert_instance_of(Styr::Backend::SSHBackend, backend)
  end

  def test_from_config_is_case_insensitive
    backend = Styr::Backend.from_config("backend" => "HEROKU", "app" => "myapp")
    assert_instance_of(Styr::Backend::HerokuBackend, backend)
  end

  def test_from_config_raises_on_unknown_backend
    error = assert_raises(RuntimeError) do
      Styr::Backend.from_config("backend" => "docker")
    end
    assert_equal("Unknown backend type: docker", error.message)
  end

  def test_from_config_raises_when_backend_missing
    assert_raises(KeyError) do
      Styr::Backend.from_config({})
    end
  end
end

# frozen_string_literal: true

require_relative "../../test_helper"

class SSHBackendTest < Minitest::Test
  def test_execute_builds_command_with_user_and_path
    backend = Styr::Backend::SSHBackend.new(
      "backend" => "ssh", "user" => "deploy", "host" => "example.com", "path" => "/opt/app"
    )
    recorded = nil
    backend.define_singleton_method(:system) { |*args| recorded = args; true }

    backend.execute("ls -la")

    assert_equal(["ssh", "-t", "deploy@example.com", "cd /opt/app && ls -la"], recorded)
  end

  def test_execute_without_user_omits_user_prefix
    backend = Styr::Backend::SSHBackend.new("backend" => "ssh", "host" => "example.com")
    recorded = nil
    backend.define_singleton_method(:system) { |*args| recorded = args; true }

    backend.execute("ls")

    assert_equal(["ssh", "-t", "example.com", "ls"], recorded)
  end

  def test_execute_without_path_skips_cd
    backend = Styr::Backend::SSHBackend.new("backend" => "ssh", "user" => "deploy", "host" => "example.com")
    recorded = nil
    backend.define_singleton_method(:system) { |*args| recorded = args; true }

    backend.execute("ls")

    assert_equal(["ssh", "-t", "deploy@example.com", "ls"], recorded)
  end

  def test_to_s
    backend = Styr::Backend::SSHBackend.new("backend" => "ssh", "host" => "example.com")
    assert_equal("SSH", backend.to_s)
  end

  def test_target_display_combines_user_host_and_path
    target = Styr::Backend::SSHBackend::Target.new(
      "staging", "user" => "deploy", "host" => "staging.example.com", "path" => "/opt/app"
    )
    assert_equal("deploy@staging.example.com:/opt/app", target.display)
  end

  def test_target_display_without_user
    target = Styr::Backend::SSHBackend::Target.new("staging", "host" => "staging.example.com", "path" => "/opt/app")
    assert_equal("staging.example.com:/opt/app", target.display)
  end
end

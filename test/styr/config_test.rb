# frozen_string_literal: true

require_relative "../test_helper"

class ConfigTest < Minitest::Test
  def test_load_returns_empty_hash_when_config_file_missing
    File.stub(:exist?, false) do
      assert_equal({}, Styr::Config.load)
    end
  end

  def test_load_parses_toml_file_when_present
    parsed = {"targets" => {"production" => {"backend" => "heroku", "app" => "myapp"}}}

    File.stub(:exist?, true) do
      TomlRB.stub(:load_file, parsed) do
        assert_equal(parsed, Styr::Config.load)
      end
    end
  end

  def test_load_memoizes_result
    File.stub(:exist?, true) do
      TomlRB.stub(:load_file, {"a" => 1}) do
        Styr::Config.load
      end

      # Even though the file would now parse differently, the memoized value is returned.
      TomlRB.stub(:load_file, {"a" => 2}) do
        assert_equal({"a" => 1}, Styr::Config.load)
      end
    end
  end
end

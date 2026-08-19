# frozen_string_literal: true

source "https://rubygems.org"

gem "toml-rb"
gem "tty-command"
gem "tty-table"

group :development, :test do
  gem "standard"
  gem "parallel", "< 2.0" # parallel 2.0+ requires Ruby >= 3.3, CI runs 3.2
end

group :test do
  gem "minitest"
  gem "minitest-mock"
  gem "rake"
end

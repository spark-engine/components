require "bundler/setup"
require "pathname"
root_path = Pathname(File.expand_path("..", __dir__))
$LOAD_PATH.unshift root_path.join("lib").to_s
require "minitest/autorun"
require "action_view/component/test_helpers"

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../config/environment.rb", __FILE__)
require "rails/test_help"

def get_html(result, css: '*')
  trim_result(result.css(css).to_html)
end

def trim_result(result)
  result.delete(" \t\r\n")
end

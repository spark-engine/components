require "bundler/setup"
require "pp"
require "pathname"
root_path = Pathname(File.expand_path("..", __dir__))
$LOAD_PATH.unshift root_path.join("lib").to_s
require "minitest/autorun"
require "action_view/component/test_helpers"

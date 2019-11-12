# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs = %w(lib test)
  t.pattern = 'test/**/*_test.rb'
end

Rake::TestTask.new(:bench) do |t|
  t.libs = %w(lib test)
  t.pattern = 'test/**/*_benchmark.rb'
end

task default: :test

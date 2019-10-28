# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "spark_components/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spark_components"
  s.version     = SparkComponents::VERSION
  s.authors     = ["Brandon Mathis"]
  s.email       = ["brandon@imathis.com"]
  s.homepage    = "https://github.com/spark-engine/components"
  s.summary     = "Simple view components for Rails 5.1+"
  s.description = "Simple view components for Rails 5.1+"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_development_dependency "rails", ">= 5.1.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "sqlite3"
end

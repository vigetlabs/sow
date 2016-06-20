$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sprig/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sprig"
  s.version     = Sprig::VERSION
  s.authors     = ["Lawson Kurtz", "Ryan Foster"]
  s.email       = ["lawson.kurtz@viget.com", "ryan.foster@viget.com"]
  s.homepage    = "http://www.github.com/vigetlabs/sprig"
  s.summary     = "Relational, environment-specific seeding for Rails apps."
  s.description = "Sprig is a library for managing interconnected, environment-specific seed data."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "appraisal"
  s.add_development_dependency "rails",            "~> 4.2.4"

  s.add_development_dependency "rspec"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "pry"

  s.add_development_dependency "generator_spec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "sqlite3"
end

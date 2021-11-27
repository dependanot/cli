# frozen_string_literal: true

require_relative "lib/dependabot/version"

Gem::Specification.new do |spec|
  spec.authors = ["mo khan"]
  spec.bindir = "exe"
  spec.description = "The Dependabot CLI"
  spec.email = ["xlgmokha@github.com"]
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.files = Dir.glob("lib/**/*.rb") + Dir.glob("exe/*") + Dir.glob("*.gemspec") + ["LICENSE.txt", "README.md"]
  spec.homepage = "https://github.com/xlgmokha/dependabot"
  spec.license = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.name = "dependabot"
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"
  spec.summary = "The Dependabot CLI"
  spec.version = Dependabot::VERSION
  spec.add_dependency "dependabot-omnibus", "~> 0.1"
  spec.add_dependency "thor", "~> 1.1"
end

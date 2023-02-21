# frozen_string_literal: true

require_relative "lib/docrb/version"

Gem::Specification.new do |spec|
  spec.name          = "docrb"
  spec.version       = Docrb::VERSION
  spec.authors       = ["Victor Gama"]
  spec.email         = ["hey@vito.io"]

  spec.summary       = "An opinionated documentation parser"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/heyvito/docrb"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/trunk/lib/docrb"
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "docrb-html", "~> 0.2"
  spec.add_dependency "parser", "~> 3.2"
  spec.add_dependency "redcarpet", "~> 3.6"
  spec.add_dependency "rouge", "~> 4.1"
  spec.metadata["rubygems_mfa_required"] = "true"
end

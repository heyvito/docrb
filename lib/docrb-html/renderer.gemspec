# frozen_string_literal: true

require_relative "lib/renderer/version"

Gem::Specification.new do |spec|
  spec.name          = "docrb-html"
  spec.version       = Renderer::VERSION
  spec.authors       = ["Victor Gama"]
  spec.email         = ["hey@vito.io"]

  spec.summary       = "Docrb's HTML Generator"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/heyvito/docrb"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/trunk/lib/docrb-html"
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.14"
  spec.add_dependency "sassc"
  spec.add_dependency "tilt"
  spec.metadata["rubygems_mfa_required"] = "true"
end

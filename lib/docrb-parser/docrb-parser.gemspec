# frozen_string_literal: true

require_relative "lib/docrb/parser/version"

Gem::Specification.new do |spec|
  spec.name = "docrb-parser"
  spec.version = Docrb::Parser::VERSION
  spec.authors = ["Victor Gama"]
  spec.email = ["hey@vito.io"]

  spec.summary = "Docrb's Ruby Parser"
  spec.description = <<~DESC
    docrb-parser is responsible for parsing Ruby sources into a structured#{" "}
    format for usage by docrb and docrb-html.
  DESC
  spec.homepage = "https://github.com/heyvito/docrb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/trunk/lib/docrb-parser"
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "prism", "~> 0.13"
end

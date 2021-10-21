# frozen_string_literal: true

module Docrb
  # Spec provides a small wrapper around Gem::Specification to provide metadata
  # about a given gem being documented.
  class Spec
    # Public: Finds a .gemspec file within the provided input folder and
    # processes it.
    #
    # input - Folder to search for a .gemspec file
    #
    # Returns a hash containing extracted information from the found gemspec
    # file. The following keys are returned: :summary, :name, :license,
    # :git_url, :authors, :host_url
    def self.parse_folder(input)
      spec = Dir["#{input}/*"].find { |f| f.end_with? ".gemspec" }
      return if spec.nil?

      data = Gem::Specification.load(spec)
      is_private = data.metadata.key? "allowed_push_host"
      {
        summary: data.summary,
        name: data.name,
        license: data.license,
        git_url: data.metadata["source_code_uri"],
        authors: data.authors,
        host_url: is_private ? nil : "https://rubygems.org/gems/#{data.name}"
      }
    end
  end
end

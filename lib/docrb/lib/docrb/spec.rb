require 'byebug'

module Docrb
  class Spec
    def self.parse_folder(input)
      spec = Dir["#{input}/*"].find { |f| f.end_with? ".gemspec" }
      return if spec.nil?

      data = Gem::Specification::load(spec)
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

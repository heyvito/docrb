# frozen_string_literal: true

class Renderer
  class Metadata
    def initialize(base)
      @data = JSON.parse(File.read("#{base}/metadata.json"))
    end

    def format_authors
      return nil if authors.nil? || authors.count.zero?
      return authors.first if authors.length == 1

      others = authors.count - 1
      "#{authors.first}, and #{others} other#{others > 1 ? "s" : ""}"
    end

    def project_links
      links = []
      links << { kind: "rubygems", href: host_url } if host_url

      if git_url
        links << if git_url.index("github.com/")
                   { kind: "github", href: git_url }
                 else
                   { kind: "git", href: git_url }
                 end
      end

      links
    end

    def method_missing(method_name, *arguments, &)
      if @data.include? method_name.to_s
        @data[method_name.to_s]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name.to_s) || super
    end
  end
end

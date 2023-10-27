# frozen_string_literal: true

class Renderer
  class Metadata
    def self.format_authors(authors)
      return nil if authors.nil? || authors.count.zero?
      return authors.first if authors.length == 1

      others = authors.count - 1
      "#{authors.first}, and #{others} other#{others > 1 ? "s" : ""}"
    end

    def self.project_links(meta)
      links = []
      links << { kind: "rubygems", href: meta[:host_url] } if meta.key? :host_url

      if meta.key? :git_url
        links << if meta[:git_url].index("github.com/")
          { kind: "github", href: meta[:git_url] }
        else
          { kind: "git", href: meta[:git_url] }
        end
      end

      links
    end
  end
end

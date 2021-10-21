# frozen_string_literal: true

module Docrb
  # Renderer provides a Redcarpet renderer with Rouge extensions
  class Renderer < Redcarpet::Render::HTML
    def initialize(extensions = {})
      super extensions.merge(link_attributes: { target: "_blank" })
    end
    include Rouge::Plugins::Redcarpet
  end

  # InlineRenderer provides a renderer for inline contents. This renderer
  # does not emit paragraph tags.
  class InlineRenderer < Renderer
    def paragraph(text)
      text
    end
  end

  # Markdown provides utilities for generating HTML from markdown contents
  class Markdown
    # Internal: Creates a new renderer based on a provided type by setting
    # sensible defaults.
    #
    # type - Type of the renderer to be initialised. Use Docrb::Renderer or
    #        InlineRenderer
    def self.make_render(type)
      Redcarpet::Markdown.new(
        type,
        fenced_code_blocks: true,
        autolink: true
      )
    end

    # Renders a given input using the default renderer.
    #
    # input - Markdown content to be rendered
    #
    # Returns an HTML string containing the rendered Markdown content
    def self.render(input)
      make_render(Renderer).render(input)
    end

    # Renders a given input using the inline renderer.
    #
    # input - Markdown content to be rendered
    #
    # Returns an HTML string containing the rendered Markdown content
    def self.inline(input)
      make_render(InlineRenderer).render(input)
    end

    # Renders a given Ruby source code into HTML
    #
    # source - Source code to be rendered
    #
    # Returns an HTML string containing the rendered source code
    def self.render_source(source)
      render("```ruby\n#{source}\n```")
    end
  end
end

module Docrb
  class Renderer < Redcarpet::Render::HTML
     def initialize(extensions = {})
       super extensions.merge(link_attributes: { target: '_blank' })
     end
     include Rouge::Plugins::Redcarpet
   end

  class InlineRenderer < Renderer
    def paragraph(text)
      text
    end
  end

  class Markdown
    def self.make_render(type)
      Redcarpet::Markdown.new(
        type,
        fenced_code_blocks: true,
        autolink: true,
      )
    end

    def self.render(input)
      make_render(Renderer).render(input)
    end

    def self.inline(input)
      make_render(InlineRenderer).render(input)
    end

    def self.render_source(source)
      self.render("```ruby\n#{source}\n```")
    end
  end
end

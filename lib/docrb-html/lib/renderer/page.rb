# frozen_string_literal: true

class Renderer
  class Page
    PAGE_BASE = Template.new(Renderer::TEMPLATES_PATH.join("base.erb"))

    def initialize(title: nil, level: 0, &body)
      @title = "#{title} - Docrb"
      @body = body || -> { "" }
      @level = level
      @make_path = -> (path) { Helpers.current_renderer.make_path(path) }
    end

    def render
      PAGE_BASE.render(Object.new,
        make_path: @make_path,
        title: @title,
        level: @level,
        body: @body.call
      )
    end

    def render_to(path) = File.write(path, render)
  end
end

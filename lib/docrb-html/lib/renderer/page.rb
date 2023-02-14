# frozen_string_literal: true

class Renderer
  class Page
    PAGE_BASE = Template.new("templates/base.erb")

    def initialize(title: nil, level: 0, &body)
      @title = "#{title} - Docrb"
      @body = body || -> { "" }
      @level = level
    end

    def render = PAGE_BASE.render(Object.new, title: @title, level: @level, body: @body.call)

    def render_to(path) = File.write(path, render)
  end
end

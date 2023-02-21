# frozen_string_literal: true

class Renderer
  class Component
    class ProjectHeader < Component
      prop :name, :description, :owner, :license, :links
    end
  end
end

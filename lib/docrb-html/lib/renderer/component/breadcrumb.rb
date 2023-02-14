# frozen_string_literal: true

class Renderer
  class Component
    class Breadcrumb < Component
      prop :project_name, :items

      def prepare
        @items ||= []
        items.unshift({ name: "Components", parents: [] })
      end
    end
  end
end

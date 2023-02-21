# frozen_string_literal: true

class Renderer
  class Component
    class ComponentList < Component
      prop :list, :parents, :class_name

      def prepare
        @list ||= []
        @parents ||= []
        nil
      end
    end
  end
end

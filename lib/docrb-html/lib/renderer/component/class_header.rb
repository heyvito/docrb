# frozen_string_literal: true

class Renderer
  class Component
    class ClassHeader < Component
      prop :type, :name, :definitions, :def_collection

      def prepare
        @definitions ||= []
        @def_collection = @definitions.dup
      end
    end
  end
end

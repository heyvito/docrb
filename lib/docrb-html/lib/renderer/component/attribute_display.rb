# frozen_string_literal: true

class Renderer
  class Component
    class AttributeDisplay < Component
      prop :item, :attr_type, :omit_link, :kind, :omit_type

      def prepare
        @attr_type = case item.type
        when :accessor then "read/write"
        when :reader then "read-only"
        else "write-only"
        end
      end
    end
  end
end

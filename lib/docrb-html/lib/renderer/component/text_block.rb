# frozen_string_literal: true

class Renderer
  class Component
    class TextBlock < Component
      prop :list

      def prepare
        return unless !@list.nil? && !@list.is_a?(Array)

        @list = [{ type: "html", contents: @list }]
      end
    end
  end
end

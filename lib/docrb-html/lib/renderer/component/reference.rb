# frozen_string_literal: true

class Renderer
  class Component
    class Reference < Component
      prop :unresolved, :path, :ref_type, :object, :value

      def prepare
        case @object
        when Docrb::Parser::Reference
          @unresolved = !@object.fulfilled?
          @path = @object.path
          return if @unresolved

          @object = @object.dereference!
          prepare
        when Docrb::Parser::Container
          @path = [@object.name]
          @ref_type = @object.kind
          parent = @object.parent
          until parent.nil?
            @path << parent.name
            parent = parent.parent
          end
          @path << ""
          @path.reverse!
        else
          @ref_type = :pure
          @value = @object[:value]
          @object = @object[:object]
        end
      end
    end
  end
end

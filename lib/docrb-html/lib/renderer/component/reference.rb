# frozen_string_literal: true

class Renderer
  class Component
    class Reference < Component
      prop :unresolved, :path, :ref_type, :object

      def prepare
        case @object
        when Docrb::Parser::Reference
          @unresolved = !@object.fulfilled?
          @path = [@object.path.last]
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
        end
      end
    end
  end
end

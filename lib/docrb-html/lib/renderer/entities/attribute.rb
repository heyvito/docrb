# frozen_string_literal: true

class Renderer
  module Entities
    class Attribute
      attr_accessor :name, :source, :definition, :overriding, :parent

      def initialize(parent, name, model)
        @name = name
        @parent = parent
        @source = model[:source] # TODO
        @definition = AttributeDefinition.new(self, model[:definition])
        @overriding = model[:overriding] # TODO
      end
    end
  end
end

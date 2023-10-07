# frozen_string_literal: true

class Renderer
  module Entities
    class AttributeDefinition
      attr_reader :defined_by, :docs, :name, :reader_visibility, :writer_visibility, :type, :parent

      def initialize(parent, model)
        @parent = parent
        @defined_by = model[:defined_by]
        @docs = model[:docs] # TODO
        @name = model[:name]
        @reader_visibility = model[:reader_visibility].to_sym
        @writer_visibility = model[:writer_visibility].to_sym
        @type = model[:type] # TODO
      end
    end
  end
end

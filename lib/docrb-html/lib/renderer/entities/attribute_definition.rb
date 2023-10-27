# frozen_string_literal: true

class Renderer
  module Entities
    class AttributeDefinition
      attr_reader :defined_by, :doc, :name, :reader_visibility, :writer_visibility, :type, :parent

      def initialize(parent, model)
        @parent = parent
        @defined_by = model[:defined_by]
        @doc = model[:doc] # TODO
        @name = model[:name]
        @reader_visibility = model[:reader_visibility].to_sym
        @writer_visibility = model[:writer_visibility].to_sym
        @type = model[:type] # TODO
      end

      def accessor? = reader? && writer?
      def reader? = reader_visibility == :public
      def writer? = writer_visibility == :public
    end
  end
end

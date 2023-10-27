# frozen_string_literal: true

module Docrb
  class Parser
    class Constant
      visible_attr_reader :name, :location
      attr_accessor :parent, :doc

      def initialize(parser, parent, node)
        @object_id = parser.make_id(self)
        @parent = parent
        @name = node.name
        @location = parser.location(node.location)
      end

      def id = @object_id
    end
  end
end

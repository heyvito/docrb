# frozen_string_literal: true

module Docrb
  class Parser
    class Attribute
      visible_attr_reader :name, :location
      visible_attr_accessor :writer_visibility, :reader_visibility, :type
      attr_accessor :parent, :doc

      def initialize(parser, parent, node, name, type)
        @object_id = parser.make_id(self)
        @name = name
        @parent = parent
        @location = parser.location(node.location)
        @type = type
        (parent.current_visibility_modifier || :public).tap do |vis|
          @writer_visibility = vis
          @reader_visibility = vis
        end
      end

      def id = @object_id
    end
  end
end

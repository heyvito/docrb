# frozen_string_literal: true

module Docrb
  class Parser
    class Call
      visible_attr_reader :name, :arguments, :parent, :location

      def initialize(parser, parent, node)
        @object_id = parser.make_id(self)
        @name = node.name.to_sym
        @arguments = []
        @parent = parent
        @location = parser.location(node.location)
        node.arguments&.arguments&.each do |arg|
          @arguments << case arg.type
          when :constant_path_node, :constant_read_node
            parser.unfurl_constant_path(arg)
          else
            arg
          end
        end
      end

      def id = @object_id
    end
  end
end

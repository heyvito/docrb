# frozen_string_literal: true

class Renderer
  module Entities
    class MethodArgument
      attr_accessor :name, :type, :value, :value_type, :parent

      def initialize(parent, arg)
        @parent = parent
        @name = arg[:name]
        @type = arg[:type].to_sym
        @value = arg[:value]
        @value_type = arg[:value_type]
      end

      def positional? = type == :arg || type == :optarg

      def optional? = type == :optarg || type == :kwoptarg

      def kwarg? = type == :kwarg || type == :kwoptarg
    end
  end
end

# frozen_string_literal: true

class Renderer
  module Entities
    class MethodDefinition
      attr_accessor :args, :defined_by, :doc, :name, :overridden_by, :visibility, :parent

      def initialize(parent, model)
        @parent = parent
        @args = model[:args].map { MethodArgument.new(self, _1) }
        @defined_by = SourceDefinition.new(model[:defined_by])
        @doc = model[:doc]
        @name = model[:name]
        @overridden_by = model[:overridden_by] # TODO
        @visibility = model[:visibility].to_sym
      end

      def protected? = visibility == :protected?

      def public? = visibility == :public?

      def private? = visibility == :private?
    end
  end
end

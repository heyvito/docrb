# frozen_string_literal: true

class Renderer
  module Entities
    class MethodDefinition
      attr_accessor :args, :defined_by, :doc, :name, :overridden_by, :visibility, :parent

      def initialize(parent, model)
        @parent = parent
        @args = model[:definition][:args].map { MethodArgument.new(self, _1) }
        @defined_by = SourceDefinition.new(nil, model[:definition][:defined_by])
        @doc = model[:definition][:doc]
        @name = model[:definition][:name]
        @overridden_by = model[:definition][:overridden_by] # TODO
        @visibility = model[:definition][:visibility].to_sym
      end

      def protected? = visibility == :protected?

      def public? = visibility == :public?

      def private? = visibility == :private?
    end
  end
end

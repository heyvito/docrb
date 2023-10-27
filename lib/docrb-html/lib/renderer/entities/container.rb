# frozen_string_literal: true

class Renderer
  module Entities
    class Container < Base
      attr_accessor :classes, :modules, :extends, :includes, :defs, :sdefs, :defined_by, :doc, :constants

      def initialize(parent, model)
        super(parent, model[:name])
        @classes = init_entities(model, :classes, as: Class)
        @modules = init_entities(model, :modules, as: Module)
        @extends = init_references!(model, :extends)
        @includes = init_references!(model, :includes)
        @constants = model[:constants] || {}
        @defs = model.fetch(:defs, {}).map { |k, v| Method.new(self, :def, k.to_s, v) }
        @sdefs = model.fetch(:sdefs, {}).map { |k, v| Method.new(self, :sdef, k.to_s, v) }
        @defined_by = init_entities(model, :defined_by, as: SourceDefinition)
      end

      def find_nested_container(named)
        @modules.find { _1.name == named } || @classes.find { _1.name == named }
      end

      def resolve_class_path(path)
        path.shift if path.first == "::"
        obj = find_nested_container(path.shift)
        return if obj.nil?

        until path.empty?
          obj = obj.find_nested_container(path.shift)
          return if obj.nil?
        end

        obj
      end

      def init_entities(model, key, as:) = model.fetch(key, []).map { as.new(self, _1) }

      def init_reference!(model, attr) = Reference.new(self, model, attr)

      def init_references!(model, key, attr: nil)
        model.fetch(key, []).map { init_reference!(_1, attr || key) }
      end

      def init_reference(model, attr)
        return if model.nil?

        Reference.new(self, model, attr)
      end
    end
  end
end

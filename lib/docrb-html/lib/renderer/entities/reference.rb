# frozen_string_literal: true

class Renderer
  module Entities
    class Reference
      def initialize(parent, model, field)
        @parent = parent
        @root = Entities.current_root
        @root.register_reference(self)

        if model.is_a? String
          @name = model
          @class_path = []
        else
          @name = model[:name]
          @class_path = model[:class_path]
        end
        @field = field
        @target = nil
        @broken = false
      end

      def resolved? = !@target.nil? || @broken

      def broken? = @broken

      def resolve!
        return __resolve_from_root__ if @class_path.first == "::"
        return __resolve_from_class_path__ unless @class_path.empty?

        location = __location__.dup
        until location.empty?
          container = location.shift.find_nested_container(@name)
          return __assign__(container) if container
        end

        __assign__ @root.find_nested_container(@name)
      end

      def method_missing(name, *)
        return @target.send(name, *) if @target.respond_to?(name)

        return @name if name == :name

        super
      end

      def respond_to_missing?(name, include_private = false)
        @target&.respond_to_missing?(name, include_private) || super
      end

      def inspect
        full_name = [@class_path, @name].flatten.join("::")
        "#<#{self.class.name}:#{object_id_hex} #{broken? ? "broken" : "valid"} reference to #{full_name}>"
      end

      def to_s = inspect

      private

      def __location__
        return @location if @location

        parents = []
        current = @parent.parent

        while current&.parent
          parents << current
          current = current.parent
        end

        @location = parents
      end

      def __broken__
        @broken = true
        nil
      end

      def __assign__(target)
        (@target = target) or __broken__
      end

      def __resolve_from_root__
        container = @root.resolve_class_path(@class_path.dup) or return __broken__
        __assign__ container.find_nested_container(@name)
      end

      def __resolve_from_class_path__
        location = __location__.dup
        container = nil

        while !container && !location.empty? && !@class_path.empty?
          container = location.shift&.find_nested_container(@class_path.first)
        end
        return __broken__ if container.nil?

        container = container.resolve_class_path(@class_path[1..].dup) or return __broken__
        __assign__ container.find_nested_container(@name)
      end
    end
  end
end

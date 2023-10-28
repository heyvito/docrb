# frozen_string_literal: true

module Docrb
  class Parser
    class Class < Container
      visible_attr_accessor :inherits, :singleton
      attr_accessor :node

      def kind = :class

      def initialize(parser, parent, node)
        @default_constructor_visibility = :public

        # WARNING: super WILL CALL methods that may require ivars to already be
        # defined. Define those ivars before this point.
        super

        @inherits = if node&.type == :class_node && !node.superclass.nil?
          reference(parser.unfurl_constant_path(node.superclass))
        end

        update_constructor_visibility!
        adjust_split_attributes! :class
        adjust_split_attributes! :instance
      end

      def unowned_classes
        super.tap do |arr|
          arr.merge_unowned(*@inherits.dereference!.all_classes) if @inherits&.fulfilled?
        end
      end

      def unowned_modules
        super.tap do |arr|
          arr.merge_unowned(*@inherits.dereference!.unowned_modules) if @inherits&.fulfilled?
        end
      end

      def unowned_instance_methods
        super.tap do |arr|
          arr.merge_unowned(*@inherits.dereference!.all_instance_methods) if @inherits&.fulfilled?
        end
      end

      def unowned_class_methods
        super.tap do |arr|
          arr.merge_unowned(*@inherits.dereference!.unowned_class_methods) if @inherits&.fulfilled?
        end
      end

      def unowned_class_attributes
        super.tap do |arr|
          arr.merge_unowned(*@inherits.dereference!.unowned_class_attributes) if @inherits&.fulfilled?
        end
      end

      def unowned_instance_attributes
        super.tap do |arr|
          arr.merge_unowned(*@inherits.dereference!.unowned_instance_attributes) if @inherits&.fulfilled?
        end
      end

      def is_inherited?(obj, parent)
        return false if parent.nil? || !parent.fulfilled?
        return true if parent.resolved.id == obj.parent.id

        deref = parent.dereference!
        return is_inherited?(obj, deref.inherits) if deref.is_a? Class

        false
      end

      def source_of(obj)
        return :inherited if is_inherited?(obj, inherits)

        super
      end

      def singleton! = tap { @singleton = true }

      def singleton? = @singleton || false

      def handle_parsed_node(parser, node) = parser.unhandled_node! node

      def merge_singleton_class(other)
        raise ArgumentError, "Cannot merge non-singleton class #{other.name} into #{name}" unless other.singleton?

        class_methods.append(*other.instance_methods)
        class_attributes.append(*other.instance_attributes)
        return if other.location.try(:virtual?)

        @defined_by << other.location
        @location = other.location if @location.nil? || @location.try(:virtual)
      end
    end
  end
end

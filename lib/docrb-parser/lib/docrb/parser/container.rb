# frozen_string_literal: true

module Docrb
  class Parser
    class Container
      visible_attr_accessor :classes, :modules, :defined_by, :instance_methods,
        :class_methods, :extends, :includes, :name, :path_segments,
        :instance_attributes, :class_attributes, :current_visibility_modifier,
        :constants, :location
      attr_accessor :parent, :parser, :doc

      SINGLETON_CLASS_TYPES = %i[
        singleton_class_node
        deferred_singleton_class_node
      ].freeze

      def initialize(parser, parent, node)
        @object_id = parser.make_id(self)
        @node = node
        @parser = parser
        @explicit_instance_visibility = {}
        @explicit_class_visibility = {}
        @constants = NodeArray.new
        @classes = NodeArray.new
        @modules = NodeArray.new
        @includes = NodeArray.new
        @extends = NodeArray.new
        @defined_by = []
        @instance_methods = NodeArray.new
        @class_methods = NodeArray.new
        @class_attributes = NodeArray.new
        @instance_attributes = NodeArray.new
        @inside_module_function = false
        @location = parser.location(node.location)
        @parent = parent

        @name = if SINGLETON_CLASS_TYPES.include? node&.type
          nil
        elsif node
          name = parser.unfurl_constant_path(node.constant_path)
          @path_segments = name
          name.pop
        end

        node&.body&.body&.each { handle_node(_1) }
      end

      def full_path(relative_to: nil)
        path = [self] + (parent&.full_path || [])
        return path unless relative_to

        rel_path = relative_to.full_path
        while rel_path.last == path.last
          rel_path.pop
          path.pop
        end

        path
      end

      def extract_references(from, attr)
        NodeArray.new(from
          .filter(&:fulfilled?)
          .map { _1.resolved.id }
          .map { parser.object_by_id(_1) }
          .map { _1.send(attr) }
          .flatten)
      end

      def unowned_classes = extract_references(@includes, :all_classes)

      def all_classes = NodeArray.new(@classes).tap { _1.merge_unowned(*unowned_classes) }

      def unowned_modules = extract_references(@includes, :all_modules)

      def all_modules = NodeArray.new(@modules).tap { _1.merge_unowned(*unowned_modules) }

      def unowned_instance_methods = extract_references(@includes, :all_instance_methods)

      def all_instance_methods = NodeArray.new(@instance_methods).tap { _1.merge_unowned(*unowned_instance_methods) }

      def unowned_class_methods = extract_references(@extends, :all_instance_methods)

      def all_class_methods = NodeArray.new(@class_methods).tap { _1.merge_unowned(*unowned_class_methods) }

      def unowned_class_attributes = extract_references(@extends, :all_instance_attributes)

      def all_class_attributes = NodeArray.new(@class_attributes).tap { _1.merge_unowned(*unowned_class_attributes) }

      def unowned_instance_attributes = extract_references(@includes, :all_instance_attributes)

      def all_instance_attributes
        NodeArray.new(@instance_attributes)
          .tap { _1.merge_unowned(*unowned_instance_attributes) }
      end

      def all_objects
        NodeArray.new(
          all_classes + all_modules + all_instance_methods + all_classes +
            all_class_attributes + all_instance_attributes
        )
      end

      def id = @object_id

      def source_of(obj)
        parent = obj.parent.id
        case
        when parent == id
          :self
        when @includes.filter(&:fulfilled?).any? { _1.resolved.id == parent }
          :included
        when @extends.filter(&:fulfilled?).any? { _1.resolved.id == parent }
          :extended
        else
          :unknown
        end
      end

      def handle_parsed_node(_parser, _node) = nil

      def instance_method_added(_parser, _node, _method) = nil

      def class_method_added(_parser, _node, _method) = nil

      def class_added(_parser, _node, _method) = nil

      def module_added(_parser, _node, _method) = nil

      def handle_call(call)
        case call.name
        when :extend
          extends.append(*call.arguments.map { reference(_1) })
          true
        when :include
          includes.append(*call.arguments.map { reference(_1) })
          true
        when :attr, :attr_reader
          add_attribute(parser, call, :reader)
          true
        when :attr_accessor
          add_attribute(parser, call, :accessor)
          true
        when :attr_writer
          add_attribute(parser, call, :writer)
          true
        when :private, :public, :protected
          handle_visibility_modifier(parser, call)
          true
        when :private_class_method, :public_class_method
          handle_singleton_visibility_modifier(parser, call)
          true
        else
          false
        end
      end

      def handle_node(node)
        case v = parse_node(node)
        when nil
          # Pass
        when Method
          if v.instance?
            @instance_methods << v
            instance_method_added(parser, node, v)
          else
            @class_methods << v
            class_method_added(parser, node, v)
          end
        when Class
          if v.singleton? && kind == :class
            merge_singleton_class(v)
          else
            @classes << v
            class_added(parser, node, v)
          end
        when Module
          @modules << v
          module_added(parser, node, v)
        when Call
          handle_parsed_node(parser, v) unless handle_call(v)
        when Constant
          @constants << v
        else
          handle_parsed_node(parser, v)
        end
      end

      def parse_node(node) = parser.handle_node(node, self)

      def reference(path) = parser.reference(self, path)

      def add_attribute(parser, node, type)
        node.arguments.each do |arg|
          next unless arg.try(:type) == :symbol_node # TODO: Support extra types?

          @instance_attributes << Attribute.new(parser, self, node, arg.value.to_sym, type)
        end
      end

      def adjust_split_attributes!(scope)
        attrs = instance_variable_get("@#{scope}_attributes")
        methods = instance_variable_get("@#{scope}_methods")
        exp = instance_variable_get("@explicit_#{scope}_visibility")

        loop do
          changed = false
          attrs.each do |attr|
            setter = "#{attr.name}=".to_sym

            # Do we have a writer defined explicitly?
            if (method = methods.named(setter).first)
              changed = true
              methods.delete(method)
              attr.writer_visibility = exp.fetch(setter, method.visibility)

              # Promote attribute to accessor in case it was only a reader.
              attr.type = :accessor if attr.type == :reader
            end

            next unless (method = methods.named(attr.name).first)

            changed = true
            methods.delete(method)
            attr.reader_visibility = exp.fetch(setter, method.visibility)

            # Promote attribute to accessor in case it was only a writer.
            attr.type = :accessor if attr.type == :writer
          end

          # Finally, move all methods ending in `=` that are left to write-only
          # attributes, and re-run this loop if required.
          methods.each do |met|
            name = met.name.to_s
            next unless name.end_with? "="

            changed = true
            attr_name = name.gsub("=", "").to_sym
            attrs << Attribute.new(@parser, self, met.node, attr_name, :writer).tap do |attr|
              attr.writer_visibility = met.visibility
            end
            methods.delete(met)
          end

          break unless changed
        end
      end

      def handle_visibility_modifier(_parser, node)
        @inside_module_function = false
        old_visibility = @current_visibility_modifier
        @current_visibility_modifier = node.name
        node.arguments&.each do |arg|
          case arg.type
          when :symbol_node
            @explicit_instance_visibility[arg.value.to_sym] = @current_visibility_modifier
            if (method = @instance_methods.named(arg.value.to_sym).first)
              method.visibility = @current_visibility_modifier
              next
            end

            if (attr = @instance_attributes.named(arg.value.gsub("=", "").to_sym).first)
              if arg.value.end_with? "="
                attr.writer_visibility = @current_visibility_modifier
              else
                attr.reader_visibility = @current_visibility_modifier
              end
            end

          when :def_node, :call_node
            @explicit_instance_visibility[arg.name.to_sym] = @current_visibility_modifier
            known_methods = @instance_methods.map(&:name)
            handle_node(arg)
            (@instance_methods.map(&:name) - known_methods).each do |n|
              @explicit_instance_visibility[n] = @current_visibility_modifier
            end
          else
            parser.unhandled_node! node
          end
        end
      ensure
        @current_visibility_modifier = old_visibility unless node.arguments && node.arguments.empty?
      end

      def handle_singleton_visibility_modifier(_parser, node)
        visibility = node.name.to_s.split("_", 2).first.to_sym
        node.arguments.each do |arg|
          if arg.value == "new"
            @default_constructor_visibility = visibility
            next
          end
          @class_methods.named(arg.value.to_sym).first&.visibility = visibility
        end
      end

      def update_constructor_visibility!
        return if @default_constructor_visibility == :public

        # Create a new "new" singleton
        handle_node(VirtualMethod.new(:new, :self_node))
        @class_methods.named(:new).first!.visibility = @default_constructor_visibility
      end
    end
  end
end

# frozen_string_literal: true

module Docrb
  class Parser
    class Module < Container
      def kind = :module

      def initialize(parser, parent, node)
        super
        adjust_split_attributes! :class
        adjust_split_attributes! :instance
      end

      def instance_method_added(_parser, _node, method)
        return unless @inside_module_function
        return unless method.instance?

        method.type = :module_function
        @class_methods.append(method)
        @instance_methods.delete(method)
      end

      def handle_parsed_node(parser, node)
        return unless node.is_a? Call
        return unless node.name == :module_function

        old_module_function = @inside_module_function
        @inside_module_function = true

        node.arguments&.each do |arg|
          case arg.type
          when :symbol_node
            if (method = @instance_methods.named(arg.value.to_sym).first)
              method.type = :module_function
              @class_methods.append(method)
              @instance_methods.delete(method)
            end

          when :def_node, :call_node
            handle_node(arg)
          else
            parser.unhandled_node! node
          end
        ensure
          @inside_module_function = old_module_function unless node.arguments && node.arguments.empty?
        end
      end
    end
  end
end

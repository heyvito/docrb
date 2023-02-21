# frozen_string_literal: true

class Renderer
  class Component
    class MethodArgument < Component
      prop :type, :name, :value, :value_type, :computed

      def prepare
        @computed = {
          rest: rest_arg,
          name:,
          continuation: continuation_for_type,
          value: value_for_argument
        }
      end

      def continuation_for_type
        if type == "kwarg" || type == "kwoptarg"
          :colon
        elsif type&.index("opt")&.zero?
          :equal
        end
      end

      REST_ARG_BY_TYPE = {
        "kwrestarg" => :double,
        "restarg" => :single,
        "blockarg" => :block
      }.freeze

      def rest_arg
        REST_ARG_BY_TYPE[type]
      end

      def value_for_argument
        return if value_type.nil?

        case value_type
        when "sym"
          { kind: :symbol, value: }
        when "bool"
          { kind: :symbol, value: value.inspect }
        when "nil"
          { kind: :symbol, value: "nil" }
        when "int"
          { kind: :number, value: }
        when "str"
          { kind: :string, value: }
        when "send"
          method_call_argument(value)
        when "const"
          const_value(value)
        else
          { kind: :plain, value: }
        end
      end

      def method_call_argument(value)
        class_path = value[:target].map do |i|
          next { kind: :symbol, value: "self" } if i == "self"

          # TODO: Is this plain?
          [{ kind: :class_or_module, value: i }, { kind: :plain, value: "::" }]
        end.flatten

        class_path.pop

        {
          kind: :method_call_argument,
          value: [
            class_path,
            { kind: :plain, value: "." },
            { kind: :plain, value: value[:name] }
          ].flatten
        }
      end

      def const_value(value)
        class_path = value[:target].map do |i|
          # TODO: Is this plain?
          [{ kind: :class_or_module, value: i }, { kind: :continuation, double: true }]
        end.flatten

        class_path.pop

        if class_path.empty?
          return {
            kind: :const,
            value: [
              { kind: :class_or_module, value: value[:name] }
            ].flatten
          }
        end

        {
          kind: :const,
          value: [
            class_path,
            { kind: :continuation, double: true },
            { kind: :class_or_module, value: value[:name] }
          ].flatten
        }
      end
    end
  end
end

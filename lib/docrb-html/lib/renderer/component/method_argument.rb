# frozen_string_literal: true

class Renderer
  class Component
    class MethodArgument < Component
      prop :type, :name, :value, :value_type, :computed, :arg

      def prepare
        @type = @arg.kind
        @name = @arg.name
        @value = @arg.value&.source
        @value_type = @arg.value_type

        @computed = {
          rest: rest_arg,
          name:,
          continuation: continuation_for_type,
          value: value_for_argument
        }
      end

      def continuation_for_type
        if arg.keyword? && !arg.rest?
          :colon
        elsif arg.optional?
          :equal
        end
      end

      REST_ARG_BY_TYPE = {
        kwrest: :double,
        rest: :single,
        block: :block
      }.freeze

      def rest_arg
        REST_ARG_BY_TYPE[type]
      end

      def value_for_argument
        return if value_type.nil?

        case value_type
        when :symbol, :bool
          { kind: :symbol, value: }
        when :nil
          { kind: :symbol, value: "nil" }
        when :number
          { kind: :number, value: }
        when :string
          { kind: :string, value: }
        when :call
          { kind: :call, value: }
        when :const
          { kind: :const, value: [value] }
        else
          { kind: :plain, value: }
        end
      end
    end
  end
end

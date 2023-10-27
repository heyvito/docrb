module Docrb
  class Parser
    class MethodParameters < Array
      def initialize(parser, parent, node)
        @object_id = parser.make_id(self)
        super()
        @parent = parent
        @node = node
        node&.compact_child_nodes&.sort_by { _1.location.start_offset }&.each do |n|
          kind = case n
          when Prism::RequiredParameterNode then :arg
          when Prism::OptionalParameterNode then :optarg
          when Prism::RestParameterNode then :rest
          when Prism::KeywordParameterNode then n.value ? :optkw : :kw
          when Prism::KeywordRestParameterNode then :kwrest
          when Prism::BlockParameterNode then :block
          else raise NotImplementedError, "Unsupported parameter kind #{n.class}"
          end
          append Parameter.new(parser, kind, n.name, n.try(:value))
        end
      end

      def id = @object_id

      docrb_inspect { to_a }

      class Parameter
        visible_attr_reader :kind, :name, :value, :value_type
        attr_reader :parser

        def initialize(parser, kind, name, value = nil)
          @object_id = parser.make_id(self)
          @kind = kind
          @name = name || name_by_type
          @value_type = type_for_value(value)
          @value = value.then! { parser.location(_1.location) }
        end

        def id = @object_id

        def has_value? = !value.nil?

        def optional? = kind == :optarg || kind == :optkw

        def positional? = kind == :optarg || kind == :arg || kind == :rest

        def keyword? = kind == :kw || kind == :optkw || kind == :kwrest

        def block? = kind == :block

        def rest? = kind == :kwrest || kind == :rest

        private

        def name_by_type
          case kind
          when :rest then :*
          when :kwrest then :**
          when :block then :&
          else
            raise "Invalid call to name_by_type for a non-anonymous parameter"
          end
        end

        def type_for_value(value)
          return unless value

          case value
          when Prism::SymbolNode then :symbol
          when Prism::NilNode then :nil
          when Prism::FalseNode, Prism::TrueNode then :bool
          when Prism::CallNode then :call
          when Prism::StringNode then :string
          when Prism::IntegerNode,Prism::FloatNode then :number
          when Prism::ConstantReadNode, Prism::ConstantPathNode then :const
          else
            puts "Unhandled parameter value type #{value.class.name}"
          end
        end
      end
    end
  end
end

module Docrb
  class Parser
    class Method
      visible_attr_accessor :name, :parameters, :visibility, :overriding,
        :overridden_by, :type, :external_receiver, :location
      attr_accessor :parent, :node, :doc

      def kind = :method

      def initialize(parser, parent, node)
        @object_id = parser.make_id(self)
        @parser = parser
        @parent = parent
        @node = node
        @name = node.name
        @visibility = parent.try(:current_visibility_modifier) || :public
        @location = parser.location(node.location) unless node.is_a? VirtualMethod
        @parameters = MethodParameters.new(parser, self, node.parameters)
        @overridden_by = []
        case node.receiver&.type
        when nil
          @type = :instance
        when :self_node
          @type = :class
        else
          @type = :class
          @external_receiver = parser.reference(self, parser.unfurl_constant_path(node.receiver))
        end
      end

      def id = @object_id

      def class? = @type == :class

      def instance? = @type == :instance

      def module_function? = @visibility == :module_function

      def external? = !@external_receiver.nil?

      def override_target = (@parser.object_by_id(@overriding) if @overriding)
      def overriders = @overridden_by.map { @parser.object_by_id(_1) }.map(&:parent).compact
      def full_path(relative_to: nil)
        path = (parent&.full_path || []).reverse + [self]
        return path unless relative_to

        full_rel = relative_to.full_path.reverse
        while full_rel.first == path.first
          full_rel.shift
          path.shift
        end

        path
      end

      docrb_inspect { "name=#{name}" }
    end
  end
end

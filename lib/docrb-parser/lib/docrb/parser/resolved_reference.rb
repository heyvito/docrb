# frozen_string_literal: true

module Docrb
  class Parser
    class ResolvedReference
      visible_attr_accessor :status

      def initialize(parser, status, id)
        @status = status
        @object_id = id
        @parser = parser
      end

      def id = @object_id

      def broken? = status == :broken
      def valid? = status == :valid

      def dereference!
        raise "Cannot dereference broken reference" if broken?

        @parser.object_by_id(id)
      end
    end
  end
end

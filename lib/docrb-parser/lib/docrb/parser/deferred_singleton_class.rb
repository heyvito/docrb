# frozen_string_literal: true
module Docrb
  class Parser
    class DeferredSingletonClass < Class
      visible_attr_reader :target

      def kind = :deferred_singleton_class

      def initialize(parser, parent, node)
        super
        @target = parser.unfurl_constant_path(node.expression)
        singleton!
      end
    end
  end
end

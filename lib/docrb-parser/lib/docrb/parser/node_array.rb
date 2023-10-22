# frozen_string_literal: true
module Docrb
  class Parser
    class NodeArray < Array
      def by_kind(*kind) = filter { _1.respond_to?(:kind) && kind.include?(_1.kind) }

      def named(name)
        name = name.to_s
        NodeArray.new(filter { _1.respond_to?(:name) && _1.name.to_s == name })
      end

      def named!(name) = named(name).first!

      def typed(*classes) = filter { |node| classes.any? { node.is_a? _1 } }

      def merge_unowned(*other)
        other
          .reject { |v| find { _1.name == v.name } }
          .then { append(*_1) unless _1.empty? }
      end
    end
  end
end

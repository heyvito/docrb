class Renderer
  module Entities
    class Base
      attr_accessor :name, :parent, :references

      def initialize(parent, name)
        @parent = parent
        @name = name
        @references = []
      end

      def type = raise NotImplementedError, "Classes inheriting Entities::Base must implement #type"

      def module? = type == :module

      def class? = type == :class

      def def? = type == :def

      def static? = type == :sdef

      def root
        obj = self
        loop do
          return obj if obj.parent.nil?

          obj = obj.parent
        end

        raise "Orphaned object"
      end

      def inspect = "#<#{self.class.name}:#{object_id_hex} #{name}>"

      def to_s = inspect

      def root? = module? && parent.nil?

      def register_reference(ref)
        @references << ref
      end

      def full_path
        parents = []
        parent = self.parent
        until parent.root?
          parents << parent
          parent = parent.parent
        end

        parents.reverse!
        parents << self
      end
    end
  end
end

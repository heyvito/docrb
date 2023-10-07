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

      def object_id_hex = "0x#{object_id.to_s(16).rjust(16, "0")}"

      def inspect = "#<#{self.class.name}:#{object_id_hex} #{name}>"

      def to_s = inspect

      def register_reference(ref)
        @references << ref
      end
    end
  end
end

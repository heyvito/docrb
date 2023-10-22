module Docrb
  class Parser
    class Reference
      visible_attr_accessor :path, :resolved
      attr_accessor :parent

      def initialize(parser, parent, path)
        @parent = parent
        @path = path
        @parser = parser
      end

      def resolved? = !resolved.nil?
      def fulfilled? = resolved? && resolved.valid?

      def dereference!
        raise "Dereference of unfulfilled reference" unless fulfilled?

        resolved.dereference!
      end
    end
  end
end

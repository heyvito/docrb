class Renderer
  module Entities
    class Method < Base
      attr_accessor :overriding, :source, :definition

      def initialize(parent, type, name, model)
        super(parent, name)
        @overriding = model[:overriding] # TODO
        @type = type
        @definition = MethodDefinition.new(self, model)
      end

      attr_reader :type
    end
  end
end

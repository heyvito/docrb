class Renderer
  module Entities
    class Class < Container
      attr_accessor :attributes, :inherits

      def initialize(parent, model)
        super(parent, model)
        @attributes = model.fetch(:attributes, {}).map { |k, v| Attribute.new(self, k.to_s, v) }
        @inherits = init_reference(model[:inherits], :inherits)
      end

      def type = :class
    end
  end
end

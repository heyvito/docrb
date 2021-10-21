module Docrb
  class DocCompiler
    class DocClass < BaseContainer
      attr_accessor :inherits, :attributes

      def initialize(parent, filename, obj)
        @inherits = nil
        @attributes = ObjectContainer.new(self, DocAttribute, always_append: true)
        super
      end

      def appended(filename, obj)
        obj.fetch(:attr_accessor, []).each do |att|
          @attributes.push(filename, att).accessor!
        end

        obj.fetch(:attr_reader, []).each do |att|
          @attributes.push(filename, att).reader!
        end

        obj.fetch(:attr_writer, []).each do |att|
          @attributes.push(filename, att).writer!
        end

        def to_h
          h = super.to_h
          h.merge({
            inherits: inherits,
            attributes: merged_attributes.map { |k, v| [k, unpack(v)] }.to_h,
          })
        end
      end
    end
  end
end

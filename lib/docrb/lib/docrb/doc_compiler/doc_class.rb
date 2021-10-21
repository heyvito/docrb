# frozen_string_literal: true

module Docrb
  class DocCompiler
    # DocClass represents a documented class
    class DocClass < BaseContainer
      attr_accessor :inherits, :attributes

      # Initializes a new instance with the provided parent, file, and object.
      #
      # parent   - The parent container holding this class definition.
      # filename - The filename defining this class.
      # obj      - The parsed class data.
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
      end

      # Returns a Hash representation of this class definition
      def to_h
        super.to_h.merge({
          inherits: inherits,
          attributes: merged_attributes.transform_values { |v| unpack(v) }
        })
      end
    end
  end
end

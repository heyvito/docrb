# frozen_string_literal: true

module Docrb
  class DocCompiler
    # DocAttribute represents a single attribute defined on a class.
    class DocAttribute < Resolvable
      attr_reader :parent, :defined_by, :name, :docs, :type, :writer_visibility,
                  :reader_visibility

      def initialize(parent, filename, obj)
        super()
        @parent = parent
        @defined_by = [filename]
        @name = obj[:name]
        @docs = obj[:docs]
        @type = nil
        @writer_visibility = obj[:writer_visibility]
        @reader_visibility = obj[:reader_visibility]
      end

      # Marks the current attribute as an accessor.
      #
      # Returns the attribute's instance for chaining.
      def accessor!
        @type = :accessor
        self
      end

      # Marks the current attribute as an reader.
      #
      # Returns the attribute's instance for chaining.
      def reader!
        @type = :reader
        self
      end

      # Marks the current attribute as an writer.
      #
      # Returns the attribute's instance for chaining.
      def writer!
        @type = :writer
        self
      end

      # Returns a Hash representing this attribute
      def to_h
        {
          defined_by:,
          name:,
          docs:,
          type:,
          writer_visibility:,
          reader_visibility:
        }
      end
    end
  end
end

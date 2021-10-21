# frozen_string_literal: true

module Docrb
  class CommentParser
    # FieldBlock represents a list of fields obtained by FieldListParser
    class FieldBlock
      attr_reader :fields

      def initialize(fields)
        @fields = fields
      end

      def to_h
        { type: :field_block, contents: fields }
      end
    end
  end
end

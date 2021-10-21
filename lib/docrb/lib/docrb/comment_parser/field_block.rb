module Docrb
  class CommentParser
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

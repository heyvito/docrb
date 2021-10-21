# frozen_string_literal: true

module Docrb
  class CommentParser
    # TextBlock represents an array of characters to be built into a single
    # text block.
    class TextBlock
      def initialize(text = nil)
        @buffer = [text].compact
      end

      def <<(obj)
        @buffer << obj
        @text = nil
      end

      def empty?
        @buffer.empty?
      end

      def match?(regexp)
        regexp.match? text
      end

      def last
        @buffer.last
      end

      def text
        @text ||= @buffer.join
      end

      def subs!(index)
        @text = nil
        @buffer = @buffer[index...]
      end

      def to_h
        { type: :text_block, contents: text.gsub(/\n  /, " ") }
      end
    end
  end
end

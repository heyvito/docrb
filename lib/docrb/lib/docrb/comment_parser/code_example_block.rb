# frozen_string_literal: true

module Docrb
  class CommentParser
    # CodeExampleBlock represents a list of characters of a code example
    class CodeExampleBlock
      attr_reader :code

      def initialize
        @code = []
      end

      def <<(text_block)
        @code << "\n" unless empty?
        @code << text_block.text
      end

      def empty?
        @code.empty?
      end

      def normalize
        @code
          .map { |txt| txt.split("\n") }
          .map { |item| item.empty? ? "" : item }
          .flatten
          .map { |line| line.gsub(/^\s{2}/, "") }
          .join("\n")
      end

      def to_h
        { type: :code_example, contents: normalize }
      end
    end
  end
end

# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class TextBlock
        attr_reader :contents
        docrb_inspect_attrs :text

        def initialize(text = nil)
          @contents = case text
          when Array then text
          when String then text.chars
          when nil then []
          else
            raise ArgumentError, "TextBlock#new called with #{text}"
          end
        end

        def <<(char)
          @contents << char
          @text = nil
        end
        def empty? = @contents.empty?
        def text = @text ||= @contents.join
        def match?(regexp) = regexp.match?(text)
        def trim_left!(index)
          @text = nil
          @contents = @contents[index...]
          nil
        end
        def split(a, b)
          [
            TextBlock.new(@contents[0...a]),
            TextBlock.new(@contents[b...])
          ]
        end

        def to_h = { type: :text_block, value: text }
      end
    end
  end
end

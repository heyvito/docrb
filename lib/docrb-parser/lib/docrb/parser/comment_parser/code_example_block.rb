# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class CodeExampleBlock
        attr_reader :contents

        def initialize
          @contents = []
        end

        def <<(text_block)
          @contents << "\n" unless empty?
          @contents << text_block.text
        end

        def empty? = @contents.empty?

        def normalize
          @contents
            .map { _1.split("\n") }
            .map { _1.empty? ? "" : _1 }
            .flatten
            .map { _1.gsub(/^\s{2}/, "") }
            .join("\n")
        end

        def to_h = { type: :code_example_block, value: normalize }
      end
    end
  end
end

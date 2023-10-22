# frozen_string_literal: true

require_relative "comment_parser/code_example_block"
require_relative "comment_parser/code_example_parser"
require_relative "comment_parser/field_block"
require_relative "comment_parser/field_list_parser"
require_relative "comment_parser/text_block"

module Docrb
  class Parser
    class Comment
      attr_reader :comments

      def initialize(parser, location)
        @location = location
        @file_path = location.file_path
        @parser = parser
        @comments = nil
        locate
      end

      def locate
        return if @location.virtual?

        lines = @parser.lines_for(@file_path, @location.ast)

        # NOTE: Regarding -1, -1 since `lines` is zero-indexed, and another -1
        # to get the line before the current location
        offset = @location.line_start - 2
        comments = []

        until offset.zero?
          line = lines[offset]
          break if line.nil?

          break unless line.strip.start_with? "#"

          comments << line
          offset -= 1
        end

        comments
          .reverse!
          .map!(&:strip)
          .map! { _1.gsub(/^#/, "") }

        indentation_level = /(\s+)/.match(comments.first)&.[](1)&.length
        comments.map! { _1[indentation_level...] } unless indentation_level.nil?
        @comments = comments.empty? ? nil : comments
      end
    end
  end
end

# frozen_string_literal: true

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

        # NOTE: Regarding -2, -1 since `lines` is zero-indexed, and another -1
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

        @comments = comments.reverse.map(&:strip)
      end
    end
  end
end

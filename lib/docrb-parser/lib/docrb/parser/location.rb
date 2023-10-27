# frozen_string_literal: true

module Docrb
  class Parser
    class Location
      visible_attr_reader :line_start, :line_end, :offset_start, :offset_end
      attr_reader :parser, :file_path, :ast, :source

      def initialize(parser, ast, loc)
        @parser = parser
        @ast = ast
        if loc.try(:virtual?)
          @virtual = true
        else
          @line_start = loc.start_line
          @line_end = loc.end_line
          @offset_start = loc.start_offset
          @offset_end = loc.end_offset
          @file_path = parser.current_file
        end

        @source = nil
      end

      def virtual? = @virtual || false

      def load_source!
        return if @virtual

        @source = @ast.source.source[@offset_start...@offset_end]
          .then do |src|
          lines = src.lines
          next src unless lines.length > 1

          match = /^(\s+)/.match(lines.last)
          next src unless match

          src.gsub(/^\s{#{match[1].length}}/, "")
        end
      end
    end
  end
end

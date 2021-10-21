# frozen_string_literal: true

module Docrb
  class CommentParser
    # FieldListParser parses a field block (representing arguments of an method,
    # for instance) into a specialised structure.
    class FieldListParser
      FIELD_FORMAT_REGEXP = /^([a-z_][0-9a-z_]*:?)\s+- /i

      def initialize(text)
        @text = text
        @data = []
        @current = []
        @result = {}
        @dash_index = nil
      end

      def detect
        @text.each_char do |c|
          next @current << c unless c == LINE_BREAK
          return false unless handle_linebreak
        end
        return false unless handle_linebreak

        flush_current_field!
        true
      end

      def handle_linebreak
        return true if @current.empty?

        # Here's a linebreak. Handle it as needed.
        @current = @current.join
        if infer_field_alignment(@current)
          flush_current_field!
          @data << @current
        else
          # This is not a field. May be a continuation.
          # Can it be a continuation?
          return false if @data.empty?

          # Yep. It may be. Is it?
          return false unless continuation?(@current)

          # It is. Append to data.
          @data << @current.strip
        end
        @current = []
        true
      end

      def flush_current_field!
        return if @data.empty?

        data = @data.join(" ")
        @data = []
        field_name = FIELD_FORMAT_REGEXP.match(data)[1]
        text = data.slice(@dash_index + 1...).strip
        @result[field_name] = text
      end

      def continuation?(line)
        return false unless @dash_index

        # until dash_index, we should have spaces
        return false if line.length < @dash_index

        return false unless line.slice(0..@dash_index + 1).strip.empty?

        true
      end

      def infer_field_alignment(line)
        # is the line a field?
        return false unless FIELD_FORMAT_REGEXP.match?(line)

        if @dash_index
          # does it match the same alignment?
          return false if line[@dash_index] != DASH
        else
          @dash_index = line.index(DASH)
        end

        true
      end

      attr_reader :result
    end
  end
end

# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class FieldListParser
        FIELD_FORMAT_REGEXP = /^([a-z_][0-9a-z_]*:?)\s+- /i

        attr_reader :result

        def initialize(text)
          @text = text
          @data = []
          @current = []
          @result = {}
          @dash_index = nil
        end

        def detect
          @text.each_char do |char|
            next @current << char unless char == LINE_BREAK
            return false unless handle_linebreak
          end
          return false unless handle_linebreak

          flush_current_field!
          true
        end

        def handle_linebreak
          return true if @current.empty?

          @current = @current.join
          if infer_field_alignment(@current)
            flush_current_field!
            @data << @current
          else
            # This is not a field. May be a continuation.
            return false if @data.empty?

            return false unless continuation?(@current)

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
          result[field_name] = [TextBlock.new(data.slice(@dash_index + 1...).strip)]
        end

        def continuation?(line)
          if @dash_index.nil? ||
             # until dash_index we should have spaces
             line.length < @dash_index ||
             !line.slice(0..@dash_index + 1).strip.empty?
            return false
          end

          true
        end

        def infer_field_alignment(line)
          return false unless FIELD_FORMAT_REGEXP.match? line
          return false if @dash_index && line[@dash_index] != DASH

          @dash_index ||= line.index(DASH)
          true
        end
      end
    end
  end
end

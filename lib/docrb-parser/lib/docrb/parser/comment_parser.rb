# frozen_string_literal: true

module Docrb
  class Parser
    # CommentParser implements a small parser for matching comment's contents to
    # relevant references and annotations.
    class CommentParser
      NEWLINE = "\n"
      POUND = "#"
      SPACE = " "
      DASH = "-"
      COLON = ":"

      attr_accessor :objects, :current_object, :cursor, :visibility

      def self.parse(data)
        new(data)
          .tap(&:parse)
          .then do |parser|
          { meta: { visibility: parser.visibility }.compact, value: parser.objects }
        end
      end

      def initialize(data)
        @objects = []
        @current_object = []
        @data = data
          .split(NEWLINE)
          .map(&:rstrip)
          .map { _1.gsub(/^\s*#\s?/, "") }
          .join(NEWLINE)
          .each_grapheme_cluster
          .to_a
        @data_len = @data.length
        @visibility = nil

        @cursor = 0
      end

      def at_end? = (cursor >= @data_len)

      def will_end? = (cursor + 1 >= @data_len)

      def at_start? = cursor.zero?

      def peek = at_end? ? nil : @data[cursor]

      def peek_next = will_end? ? nil : @data[cursor + 1]

      def peek_prev = at_start? ? nil : @data[cursor - 1]

      def advance = at_end? ? nil : peek.tap { self.cursor += 1 }

      def match?(*args) = args.any? { _1 == peek }

      def consume_spaces = (advance while match?(SPACE) && !at_end?)

      def extract_while = (current_object << advance while yield && !at_end?)

      def extract_until
        until at_end?
          break if yield

          current_object << advance
        end
      end

      def parse
        parse_one until at_end?
        flush_current_object
        detect_field_list
        process_code_examples
        process_text_blocks
        process_visibility
        objects.map! { normalize_tree(_1) }
        true
      end

      def flush_current_object
        data = current_object.join.rstrip
        return if data.empty?

        objects << data
        current_object.clear
      end

      def parse_one
        extract_until { match? NEWLINE }
        advance # Consume newline
        if match? NEWLINE
          advance # consume newline
          flush_current_object
          return
        end
        current_object << peek_prev if peek_prev == NEWLINE
      end

      FIELD_LIST_HEADING = /^([a-z][a-z_0-9]*:?)\s+-\s+(.*)/

      def detect_field_list
        objects.each.with_index do |obj, idx|
          definitions = obj.split("\n").reject { _1.start_with? SPACE }

          if (definitions.length == 1 && definitions.first =~ FIELD_LIST_HEADING) ||
             (definitions.first =~ FIELD_LIST_HEADING && definitions[1] =~ FIELD_LIST_HEADING)
            return process_field_list(obj, idx)
          end
        end
      end

      def process_field_list(obj, at)
        lines = obj.lines
        result = {}
        last_key = nil
        lines.each do |line|
          if (match = FIELD_LIST_HEADING.match(line))
            last_key = match[1]
            contents = match[2]
            result[last_key] = contents
          elsif last_key
            result[last_key] = "#{result[last_key]} #{line.lstrip}"
          end
        end
        objects[at] = { type: :fields, value: result }
      end

      def process_text_blocks
        objects.each.with_index do |obj, idx|
          next objects[idx] = process_text_block(obj) if obj.is_a? String

          case obj[:type]
          when :fields
            obj[:value].transform_values! { process_text_block(_1) }
          when :code_example then next
          else
            raise NotImplementedError, "Can't process text block for type #{obj[:type]}"
          end
        end
      end

      def span(text) = { type: :span, value: text }

      def process_text_block(text)
        objs = [span(text)]
        changed = true
        while changed
          changed = false
          objs.each.with_index do |obj, idx|
            next unless obj[:type] == :span

            value = obj[:value]
            changes = extract_method_reference(value) ||
                      extract_symbol(value) ||
                      extract_camelcase_identifier(value)
            next unless changes

            changes => { start_idx:, end_idx:, object: }
            objs.delete_at(idx)
            left = value[0...start_idx]
            right = value[end_idx...]

            new_items = [
              (span(left) unless left.empty?),
              object,
              (span(right) unless right.empty?)
            ]
            objs.insert(idx, *new_items.compact)
            changed = true
            break
          end
        end
        objs.length == 1 ? objs.first : objs
      end

      # rubocop:disable Layout/LineLength
      COMMENT_METHOD_REF_REGEXP = /(?:([A-Z][a-zA-Z0-9_]*::)*([A-Z][a-zA-Z0-9_]*))?(::|\.|#)([A-Za-z_][a-zA-Z0-9_@]*[!?]?)(?:\([a-zA-Z0-9=_,\s*]+\))?/
      # rubocop:enable Layout/LineLength

      def extract_method_reference(text)
        match = COMMENT_METHOD_REF_REGEXP.match(text) or return nil
        value, class_path, target, invocation, name = match.to_a
        class_path&.gsub!(/::$/, "")

        {
          start_idx: match.begin(0),
          end_idx: match.end(0),
          object: {
            type: invocation == POUND ? :method_ref : :class_path_ref,
            class_path:,
            target:,
            name:,
            value:
          }
        }
      end

      COMMENT_SYMBOL_REGEXP = /:(!|[@$][a-z_][a-z0-9_]*|[a-z_][a-z0-9_]*|[a-z_][a-z0-9_]*[?!]?)/i

      def extract_symbol(text)
        match = COMMENT_SYMBOL_REGEXP.match(text) or return nil

        {
          start_idx: match.begin(0),
          end_idx: match.end(0),
          object: {
            type: :symbol,
            value: match[0]
          }
        }
      end

      CAMELCASE_IDENTIFIER_REGEXP = /[A-Z][a-z]+(?:[A-Z][a-z]+)+/

      def extract_camelcase_identifier(text)
        match = CAMELCASE_IDENTIFIER_REGEXP.match(text) or return nil

        {
          start_idx: match.begin(0),
          end_idx: match.end(0),
          object: {
            type: :identifier,
            value: match[0]
          }
        }
      end

      VISIBILITY_INDICATOR_REGEXP = /^\s*(public|private|internal|deprecated|protected):\s+/i

      def process_visibility(obj = nil)
        obj ||= objects.first
        case obj
        when Array then process_visibility(obj.first)
        when Hash
          return if obj[:type] == :fields
          return process_visibility(obj[:value]) unless obj[:type] == :span

          value = obj[:value]
          match = VISIBILITY_INDICATOR_REGEXP.match(value) or return nil
          obj[:value] = value[match.end(0)...]
          @visibility = match[1]
          nil
        end
      end

      def process_code_examples
        changed = true
        while changed
          start_at = nil
          changed = false
          objects.each.with_index do |obj, idx|
            is_code = (obj.is_a?(String) && obj.start_with?("  "))
            next start_at = idx if is_code && start_at.nil?

            if !is_code && start_at
              join_code_example_lines(start_at, idx)
              start_at = nil
              changed = true
              break
            end
          end
          join_code_example_lines(start_at, objects.length) unless start_at.nil?
        end
      end

      def join_code_example_lines(start_at, end_at)
        lines = objects[start_at...end_at]
          .map { _1.split("\n") }
          .map { |el| el.map { "#{_1[2...]}\n" } }
          .flatten
        objects.slice!(start_at...end_at)
        objects.insert(start_at, {
          type: :code_example,
          source: lines.join("\n")
        })
      end

      def normalize_tree(obj)
        if obj.is_a?(Array)
          { type: :block, value: obj }
        elsif obj.is_a?(Hash) && obj[:type] == :span
          { type: :block, value: [obj] }
        elsif obj.is_a?(Hash) && obj[:type] == :fields
          obj.tap { |f| f[:value].transform_values! { normalize_tree(_1) } }
        else
          obj
        end
      end
    end
  end
end

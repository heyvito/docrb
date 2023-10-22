# frozen_string_literal: true

require_relative "comment_parser/camel_case_identifier"
require_relative "comment_parser/code_example_block"
require_relative "comment_parser/code_example_parser"
require_relative "comment_parser/field_block"
require_relative "comment_parser/field_list_parser"
require_relative "comment_parser/reference"
require_relative "comment_parser/symbol"
require_relative "comment_parser/text_block"

module Docrb
  class Parser

    # CommentParser implements a small parser for matching comment's contents to
    # relevant references and annotations.
    class CommentParser
      COMMENT_METHOD_REF_REGEXP = /(?:([A-Z][a-zA-Z0-9_]*::)*([A-Z][a-zA-Z0-9_]*))?(::|\.|#)([A-Za-z_][a-zA-Z0-9_@]*[!?]?)(?:\([a-zA-Z0-9=_,\s*]+\))?/
      COMMENT_SYMBOL_REGEXP = /:(!|[@$][a-z_][a-z0-9_]*|[a-z_][a-z0-9_]*|[a-z_][a-z0-9_]*[?!]?)/i
      CAMELCASE_IDENTIFIER_REGEXP = /[A-Z][a-z]+(?:[A-Z][a-z]+)+/
      INTERNAL_ANNOTATION_REGEXP = /^internal:/i
      PUBLIC_ANNOTATION_REGEXP = /^public:/i
      PRIVATE_ANNOTATION_REGEXP = /^private:/i
      DEPRECATED_ANNOTATION_REGEXP = /^deprecated:/i
      VISIBILITY_ANNOTATIONS = {
        internal: INTERNAL_ANNOTATION_REGEXP,
        public: PUBLIC_ANNOTATION_REGEXP,
        private: PRIVATE_ANNOTATION_REGEXP,
        deprecated: DEPRECATED_ANNOTATION_REGEXP
      }.freeze
      CARRIAGE = "\r"
      LINE_BREAK = "\n"
      SPACE = " "
      DASH = "-"

      def self.parse(comment)
        new.parse(comment)
      end

      def initialize
        @components = []
        @current = TextBlock.new
        @last_char = nil
        @current_char = nil
        @meta = {}
      end

      def commit_current!
        @components << @current if @current && !@current.empty?
        @current = TextBlock.new
      end

      # Parses a given comment into its structured form.
      #
      # data - A string containing the object's documentation.
      #
      # Returns a Hash containing the parsed content for the comment.
      def parse(data)
        load(data)
        coalesce_field_list
        detect_code_example
        infer_visibility
        detect_references
        cleanup
        to_h
      end

      def to_h = { meta: @meta, value: @components.map(&:to_h) }

      # Internal: Removes any empty or redundant components from the list.
      #
      # Returns nothing.
      def cleanup
        loop do
          changed = false
          @components.each.with_index do |elem, idx|
            case elem
            when TextBlock
              next unless elem.empty?

              @components.delete_at(idx)
              break changed = true
            when FieldBlock
              next unless elem.cleanup

              break changed = true
            end
          end
          break unless changed
        end
      end

      # Internal: Loads a given string into the parser, by splitting it into
      # text blocks.
      def load(text)
        text.each_char do |c|
          @last_char = @current_char
          @current_char = c
          next if c == CARRIAGE

          next commit_current! if @last_char == LINE_BREAK && (c == LINE_BREAK)

          @current << c
        end

        commit_current!
      end

      # Internal: Attempts to find and split field lists from the loaded
      # comment.
      def coalesce_field_list
        return if @field_list_coalesced

        @field_list_coalesced = true

        @components.each.with_index do |elem, index|
          parser = FieldListParser.new(elem.text)
          next unless parser.detect

          @components[index] = FieldBlock.new(parser.result)
          break
        end
      end

      # Internal: Attempts to find and extract code examples contained within
      # the comment
      def detect_code_example
        return if @code_example_detected

        @code_example_detected = true

        @components = CodeExampleParser.process(@components)
      end

      # Internal: Attempts to infer an object visibility based on the comment's
      # prefix. Supported visibility options are `public:`, `private:`, and
      # `internal:`. Annotations are case-insensitive.
      # This method also removes the detected annotation from the comment block,
      # to reduce clutter in the emitted documentation.
      def infer_visibility
        return if @components.empty?

        item = @components.first
        return unless item.is_a? TextBlock
        unless (annotation = VISIBILITY_ANNOTATIONS.find { |_k, v| v.match? item.text })
          return
        end

        item.trim_left! item.text.index(":") + 1
        @meta[:visibility_annotation] = annotation.first # TODO: first?
      end

      # Internal: Attempts to detect references in the current list of
      # components
      #
      # Returns nothing.
      def detect_references
        loop do
          stop_outer = true
          catch :stop_inner do
            @components.each.with_index do |elem, idx|
              case elem
              when TextBlock
                changed, new = detect_text_references(elem)
                @components.delete_at(idx)
                @components.insert(idx, *new)
                if changed
                  stop_outer = false
                  throw :stop_inner
                end
              when FieldBlock then
                changed = false
                elem.fields.transform_values { changed ||= detect_field_references(_1) }
                if changed
                  stop_outer = false
                  throw :stop_inner
                end
              end
            end
          end
          break if stop_outer
        end
      end

      # Internal: Attempts to detect references on a text object.
      #
      # text - Text data to have references transformed into specialised objects
      #
      # Returns an array containing the updated text data
      def detect_text_references(object)
        objects = [object]
        continue = true
        changed = false
        while continue
          continue = update_next_reference(objects)
          changed ||= continue
        end
        [changed, objects]
      end

      # Internal: Attempts to detect field references on a given field object.
      #
      # Returns a new hash containing the field's data post-processed with
      # reference annotations
      def detect_field_references(objects)
        continue = true
        changed = false
        while continue
          continue = update_next_reference(objects)
          changed ||= continue
        end
        changed
      end

      # Internal: Recursively updates a given value until all references are
      # processed.
      #
      # list - List of objects to be updated
      #
      # Returns nothing.
      def update_next_reference(list)
        changed = false
        list.each.with_index do |elem, idx|
          next unless elem.is_a? TextBlock

          case elem.text
          when COMMENT_METHOD_REF_REGEXP
            obj = list.delete_at(idx)
            list.insert(idx, *process_comment_method_reference(obj, Regexp.last_match))
            changed = true
          when COMMENT_SYMBOL_REGEXP
            obj = list.delete_at(idx)
            list.insert(idx, *process_symbol(obj, Regexp.last_match))
            changed = true
          when CAMELCASE_IDENTIFIER_REGEXP
            obj = list.delete_at(idx)
            list.insert(idx, *process_identifier(obj, Regexp.last_match))
            changed = true
          end
        end
        changed
      end

      def process_comment_method_reference(obj, match)
        class_path, target, invocation, name = match.to_a.slice(1...)
        class_path&.gsub!(/::$/, "")
        reference_type = invocation == "#" ? :method : :ambiguous
        begin_at = match.begin(0)
        end_at = match.end(0)
        left_slice, right_slice = obj.split(begin_at, end_at)
        [
          left_slice,
          Reference.new(ref_type: reference_type, name:, target:, class_path:, value: match[0]),
          right_slice,
        ]
      end

      def process_symbol(obj, match)
        begin_at = match.begin(0)
        end_at = match.end(0)
        left_slice, right_slice = obj.split(begin_at, end_at)
        [
          left_slice,
          Symbol.new(match[0]),
          right_slice
        ]
      end

      def process_identifier(obj, match)
        begin_at = match.begin(0)
        end_at = match.end(0)
        left_slice, right_slice = obj.split(begin_at, end_at)
        [
          left_slice,
          CamelCaseIdentifier.new(match[0]),
          right_slice
        ]
      end
    end
  end
end

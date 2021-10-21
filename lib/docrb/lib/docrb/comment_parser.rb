# frozen_string_literal: true

module Docrb
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
      depreacated: DEPRECATED_ANNOTATION_REGEXP
    }.freeze
    CARRIAGE = "\r"
    LINE_BREAK = "\n"
    SPACE = " "
    DASH = "-"

    autoload :TextBlock, "docrb/comment_parser/text_block"
    autoload :FieldListParser, "docrb/comment_parser/field_list_parser"
    autoload :CodeExampleParser, "docrb/comment_parser/code_example_parser"
    autoload :FieldBlock, "docrb/comment_parser/field_block"
    autoload :CodeExampleBlock, "docrb/comment_parser/code_example_block"

    # Parses a given comment for a given object type.
    #
    # type:    - Type of the object's to which the comment data belongs to
    # comment: - A string containing the object's documentation.
    #
    # Returns a Hash containing the parsed content for the comment.
    def self.parse(type:, comment:)
      new(type).parse(comment)
    end

    # Internal: Initializes a new parser with a provided type
    #
    # type - Type of the object being documented
    def initialize(type)
      @type = type
      @components = []
      @current = TextBlock.new
      @last_char = nil
      @current_char = nil
      @meta = {}
    end

    # Intenral: Loads the provided data into the parser and executes all steps
    # required to extract relevant information and annotations.
    #
    # data - String containing the comment being parsed
    #
    # Returns a Hash containing the parsed content for the comment.
    def parse(data)
      load(data)
      coalesce_field_list
      detect_code_example

      infer_visibility_from_doc if %i[def sdef].include? @type

      data = to_h
      data[:contents] = detect_references(data[:contents])
      data
    end

    # Internal: Attempts to infer an object visiblity based on the comment's
    # prefix. Supported visibility options are `public:`, `private:`, and
    # `internal:`. Annotations are case-insensitive.
    # This method also removes the detected annotation from the comment block,
    # to reduce clutter in the emitted documentation.
    def infer_visibility_from_doc
      return if @components.empty?

      item = @components.first
      return unless item.is_a? TextBlock
      return unless (annotation = VISIBILITY_ANNOTATIONS.find { |_k, v| v.match?(item.text) })

      item.subs! item.text.index(":") + 1
      @meta[:doc_visibility_annotation] = annotation.first
    end

    # Internal: Commits the current text block being processed by #load
    def commit_current!
      @components << @current if @current && !@current.empty?
      @current = TextBlock.new
    end

    # Internal: Loads a given stirng into the parser, by splitting it into
    # text blocks.
    def load(text)
      text.each_char do |c|
        @last_char = @current_char
        @current_char = c
        next if c == CARRIAGE

        if @last_char == LINE_BREAK && (c == LINE_BREAK)
          commit_current!
          next
        end
        @current << c
      end
      commit_current!
    end

    # Internal: Attempts to find and split field lists from the loaded comment.
    def coalesce_field_list
      return if @field_list_coalesced

      @field_list_coalesced = true

      new_contents = []
      has_field_list = false

      @components.each do |block|
        unless has_field_list
          parser = FieldListParser.new(block.text)
          if parser.detect
            has_field_list = true
            new_contents << FieldBlock.new(parser.result)
            next
          end
        end
        new_contents << block
      end

      @components = new_contents
    end

    # Internal: Attempts to find and extract code examples contained within the
    # comment
    def detect_code_example
      return if @code_examples_detected

      @code_examples_detected = true

      @components = CodeExampleParser.process(@components)
    end

    # Internal: Attempts to detect references on a provided list of blocks
    #
    # on - List of blocks to process
    #
    # Returns an updated list of blocks with references transformed into
    # specialised structures.
    def detect_references(on)
      new_contents = []

      on.each do |block|
        case block[:type]
        when :text_block
          block[:contents] = detect_text_references(block[:contents])
        when :field_block
          block[:contents] = detect_field_references(block[:contents])
        end
        new_contents << block
      end

      new_contents
    end

    # Internal: Attempts to detect references on a text object.
    #
    # text - Text data to have references transformed into specialised objects
    #
    # Returns an array containing the updated text data
    def detect_text_references(text)
      changed = true
      text, changed = update_next_reference(text) while changed
      text
    end

    # Internal: Attempts to detect field references on a given field object.
    #
    # Returns a new hash containing the field's data post-processed with
    # reference annotations
    def detect_field_references(field)
      field
        .transform_values do |v|
          { type: :text_block, contents: detect_text_references(v) }
        end
    end

    def process_comment_method_reference(contents, match)
      class_path, target, invocation, name = match.to_a.slice(1...)
      class_path&.gsub! /::$/, ""
      reference_type = invocation == "#" ? :method : :ambiguous
      begin_at = match.begin(0)
      end_at = match.end(0)
      left_slice = contents[0...begin_at]
      right_slice = contents[end_at...]
      item = {
        type: :ref,
        ref_type: reference_type,
        name: name,
        target: target,
        class_path: class_path,
        contents: match[0]
      }
      [
        { type: :span, contents: left_slice },
        item,
        { type: :span, contents: right_slice }
      ].reject { |i| i[:contents].empty? }
    end

    def process_simple_symbol(type, contents, match)
      begin_at = match.begin(0)
      end_at = match.end(0)
      left_slice = contents[0...begin_at]
      right_slice = contents[end_at...]
      [
        { type: :span, contents: left_slice },
        { type: type, contents: match[0] },
        { type: :span, contents: right_slice }
      ].reject { |i| i[:contents].empty? }
    end

    def update_string_reference(contents)
      updated = false
      if (match = COMMENT_METHOD_REF_REGEXP.match(contents))
        contents = process_comment_method_reference(contents, match)
        updated = true
      elsif (match = COMMENT_SYMBOL_REGEXP.match(contents))
        contents = process_simple_symbol(:sym_ref, contents, match)
        updated = true
      elsif (match = CAMELCASE_IDENTIFIER_REGEXP.match(contents))
        contents = process_simple_symbol(:camelcase_identifier, contents, match)
        updated = true
      end
      [contents, updated]
    end

    # Internal: Recursivelly updates a given value until all references are
    # processed.
    #
    # contents - Contents to be processed
    #
    # Returns a new array containing the processed contents
    def update_next_reference(contents)
      return update_string_reference(contents) if contents.is_a? String

      new_contents = []
      changed = false
      contents.each do |block|
        if block[:type] == :span
          updated, ok = update_next_reference(block[:contents])
          if ok
            changed = true
            next new_contents.append(*updated)
          end
        end
        new_contents << block
      end

      [new_contents, changed]
    end

    # Public: Returns a hash by merging contents and metadata obtained through
    # the parsing process.
    def to_h
      @meta.merge({
                    type: @type,
                    contents: @components.map(&:to_h)
                  })
    end
  end
end

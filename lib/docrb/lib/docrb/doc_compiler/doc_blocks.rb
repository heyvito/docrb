# frozen_string_literal: true

module Docrb
  class DocCompiler
    # DocBlocks provides utilities for annotating and formatting documentation
    # blocks.
    class DocBlocks
      # Internal: Transforms a provided reference on a given parent by a
      # ttempting to resolve it into a specific object.
      #
      # ref    - Reference to be resolved
      # parent - The reference's parent
      #
      # Returns the reference itself by augmenting it with :ref_type and
      # :ref_path information.
      def self.process_reference(ref, parent)
        return process_method_reference(ref, parent) if ref[:ref_type] == :method
        return ref if ref[:ref_type] != :ambiguous

        resolved = parent.resolve_ref(ref)
        if resolved.nil?
          ref[:ref_type] = :not_found
          return ref
        end
        ref[:ref_type] = resolved.type
        ref[:ref_path] = resolved.path
        ref
      end

      def self.process_method_reference(ref, parent)
        if (resolved = parent.resolve_ref(ref))
          ref[:ref_path] = resolved.path
        end
        ref
      end

      # Internal: Processes a identifier on a provided parent. Returns an
      # augmented reference with extra location information whenever it can
      # be resolved.
      #
      # id     - Identifier to be processed
      # parent - Parent on which the identifier appeared.
      def self.process_identifier(id, parent)
        resolved = parent.resolve(id[:contents].to_sym)
        if resolved.nil?
          puts "Unresolved: #{id[:contents]} on #{parent.path}"
          return {
            type: :span,
            contents: Markdown.inline("`#{id[:contents]}`")
          }
        end
        {
          type: :ref,
          ref_type: resolved.type,
          ref_path: resolved.path,
          contents: id[:contents]
        }
      end

      # Internal: Formats a given TextBlock object by expanding its contents
      # into markdown annotations and attempting to resolve references and
      # identifiers.
      #
      # Returns the updated block list.
      def self.format_text_block(block, parent)
        unless block[:contents].is_a? Array
          block[:contents] = Markdown.inline(block[:contents])
          return block
        end
        block[:contents].map! do |c|
          case c[:type]
          when :span
            c[:contents] = Markdown.inline(c[:contents])
          when :ref
            c = process_reference(c, parent)
          when :camelcase_identifier
            c = process_identifier(c, parent)
          end
          c
        end
        block
      end

      # Public: Updates a given documentation block by augmenting markdown
      # elements, references, fields and identifiers.
      #
      # doc    - Documentation block to be processed
      # parent - The parent container to which the block belongs to.
      #
      # Returns the updated block.
      def self.prepare(doc, parent: nil)
        return unless doc

        doc[:contents].map! do |block|
          case block[:type]
          when :text_block
            format_text_block(block, parent)
          when :code_example
            block[:contents] = Markdown.render_source(block[:contents])
          when :field_block
            block[:contents] = block[:contents].transform_values { |v| format_text_block(v, parent) }
          else
            puts "Skipped block with type #{block[:type]}"
          end
          block
        end
        doc
      end
    end
  end
end

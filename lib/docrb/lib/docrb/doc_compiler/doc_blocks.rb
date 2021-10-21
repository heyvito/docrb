require 'byebug'
module Docrb
  class DocCompiler
    class DocBlocks
      def self.process_reference(ref, parent)
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

      def self.process_identifier(id, parent)
        resolved = parent.resolve(id[:contents].to_sym)
        if resolved.nil?
          puts "Unresolved: #{id[:contents]} on #{parent.path}"
          return {
            type: :span,
            contents: Markdown.inline("`#{id[:contents]}`"),
          }
        end
        {
          type: :ref,
          ref_type: resolved.type,
          ref_path: resolved.path,
          contents: id[:contents],
        }
      end

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

      def self.prepare(doc, parent: nil)
        return unless doc
        doc[:contents].map! do |block|
          case block[:type]
          when :text_block
            format_text_block(block, parent)
          when :code_example
            block[:contents] = Markdown.render_source(block[:contents])
          when :field_block
            block[:contents] = block[:contents].map { |k, v| [k, format_text_block(v, parent)] }.to_h
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

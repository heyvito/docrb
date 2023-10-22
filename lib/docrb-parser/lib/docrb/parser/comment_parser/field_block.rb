module Docrb
  class Parser
    class CommentParser
      # FieldBlock represents a list of fields obtained by FieldListParser
      class FieldBlock
        attr_reader :fields

        def initialize(fields) = @fields = fields

        def cleanup
          updated = false
          fields.each_value { updated ||= cleanup_list _1 }
          updated
        end

        def cleanup_list(list)
          updated = false
          loop do
            changed = false
            list.each.with_index do |elem, idx|
              next unless elem.is_a? TextBlock

              if elem.empty?
                changed = true
                updated = true
                break list.delete_at(idx)
              end
            end
            break unless changed
          end
          updated
        end

        def to_h = { type: :field_block, value: fields.transform_values { _1.map(&:to_h) } }
      end
    end
  end
end

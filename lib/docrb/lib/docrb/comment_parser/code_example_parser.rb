# frozen_string_literal: true

module Docrb
  class CommentParser
    # CodeExampleParser attempts to extract code examples from a documentation
    # block.
    class CodeExampleParser
      def self.process(components)
        new_components = []
        code_example_group = CodeExampleBlock.new
        components.each do |c|
          if !c.is_a?(TextBlock) || !c.text.start_with?("  ")
            unless code_example_group.empty?
              new_components << code_example_group
              code_example_group = CodeExampleBlock.new
            end
            new_components << c
            next
          end

          code_example_group << c
        end

        new_components << code_example_group unless code_example_group.empty?
        new_components
      end
    end
  end
end

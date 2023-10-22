# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class CodeExampleParser
        def self.process(components)
          code_example_group = CodeExampleBlock.new
          [].tap do |new_components|
            components.each do |elem|
              if !elem.is_a?(TextBlock) || !elem.text.start_with?("  ")
                unless code_example_group.empty?
                  new_components << code_example_group
                  code_example_group = CodeExampleBlock.new
                end
                next new_components << elem
              end

              code_example_group << elem
            end

            new_components << code_example_group unless code_example_group.empty?
          end
        end
      end
    end
  end
end

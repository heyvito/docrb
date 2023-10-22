# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class CamelCaseIdentifier
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def to_h = { type: :camel_case_identifier, value: name }
      end
    end
  end
end

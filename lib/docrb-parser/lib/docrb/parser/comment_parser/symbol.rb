# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class Symbol
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def to_h = { type: :symbol, value: name }
      end
    end
  end
end

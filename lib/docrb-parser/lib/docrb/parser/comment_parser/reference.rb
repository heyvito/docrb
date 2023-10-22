# frozen_string_literal: true

module Docrb
  class Parser
    class CommentParser
      class Reference
        attr_accessor :ref_type, :name, :target, :class_path, :value

        def initialize(ref_type:, name:, target:, class_path:, value:)
          @ref_type = ref_type
          @name = name
          @target = target
          @class_path = class_path
          @value = value
        end

        def to_h = { type: :reference, ref_type:, name:, target:, class_path:, value: }.compact
      end
    end
  end
end

# frozen_string_literal: true

class Renderer
  module Entities
    class SourceDefinition
      attr_accessor :end_at, :start_at, :source, :markdown_source, :filename

      def initialize(_parent, model)
        @end_at = model[:end_at]
        @start_at = model[:start_at]
        @source = model[:source]
        @markdown_source = model[:markdown_source]
        @filename = model[:filename]
      end
    end
  end
end

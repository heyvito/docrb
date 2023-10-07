# frozen_string_literal: true
class Renderer
  module Entities
    class Module < Container
      def type = :module

      def initialize(parent, model)
        if parent.nil?
          as_root { super }
        else
          super
        end
      end

      def resolve_references! = @references.each(&:resolve!)

      private

      def as_root
        old_root = Entities.current_root
        Entities.current_root = self
        yield
      ensure
        Entities.current_root = old_root
      end
    end
  end
end

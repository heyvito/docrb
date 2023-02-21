# frozen_string_literal: true

class Renderer
  class Defs
    class SpecializedProjection < Array
      def initialize(provider)
        super()
        @provider = provider
        replace((provider.modules + provider.classes)
          .map { provider.specialize_object _1 }
          .each(&:prepare_inheritance))
      end

      def find_path(path)
        path = @provider.path_of(path) unless path.is_a? Array
        p = path.dup
        obj = find { _1.name == p.first }
        p.shift
        return unless obj

        until p.empty?
          obj = obj.resolve(p.first)
          p.shift
          return unless obj
        end

        obj
      end
    end
  end
end

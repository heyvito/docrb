# frozen_string_literal: true

class Renderer
  class Component
    class Reference < Component
      prop :ref, :unresolved, :path

      def prepare
        @unresolved = !ref[:ref_path]
        return if @unresolved

        components = ref[:ref_path].dup
        @path = if ref[:ref_type] == "method"
                  method_name = components.pop
                  parent_name = components.pop
                  components + ["#{parent_name}.html#{method_name}"]
                else
                  last = components.pop
                  (components + ["#{last}.html"]).compact
                end
      end
    end
  end
end

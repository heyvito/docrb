# frozen_string_literal: true

class Renderer
  class Component
    class MethodDisplay < Component
      prop :visibility, :type, :name, :href, :args, :doc, :decoration, :short_type
    end
  end
end

module Emrb
  module Instruments
    module ClassMethods
      def counter(identifier, docs, **) end
    end

    class State
      class << self
        def counter(identifier, docstring, **) end
      end
    end
  end
end
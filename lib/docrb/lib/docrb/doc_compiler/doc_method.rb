module Docrb
  class DocCompiler
    class DocMethod < Resolvable

      attr_reader :parent, :type, :name, :args, :doc, :visibility,
                  :overriden_by, :defined_by

      def initialize(parent, filename, obj)
        @parent = parent
        @type = obj[:type]
        @name = obj[:name]
        @args = obj[:args]
        @doc = obj[:doc]
        @visibility = obj[:visibility]
        @overriden_by = nil
        @defined_by = FileRef.new(nil, filename, obj)
      end

      def override(filename, obj)
        @overriden_by = DocMethod.new(@parent, filename, obj)
      end

      def override!(method)
        @overriden_by = method
      end

      def inspect
        type = @type == :def ? "method" : "singleton method"
        overriden = overriden_by.nil? ? "" : " overriden"
        "#<DocMethod:#{format("0x%08x", object_id * 2)} #{visibility} #{type} #{name}#{overriden}>"
      end

      def to_h
        {
          type: type,
          name: name,
          args: args,
          doc: DocBlocks.prepare(doc, parent: self),
          visibility: visibility,
          overriden_by: overriden_by,
          defined_by: defined_by&.to_h,
        }
      end
    end
  end
end

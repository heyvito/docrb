# frozen_string_literal: true

module Docrb
  class DocCompiler
    # DocMethod represents a documented method
    class DocMethod < Resolvable
      attr_reader :parent, :type, :name, :args, :doc, :visibility,
                  :overriden_by, :defined_by

      # Initializes a new DocMethod instance with a given parent, path, and
      # object.
      #
      # parent   - The object holding the represented method
      # filename - The filename on which the method is defined on
      # obj      - The method definition itself
      def initialize(parent, filename, obj)
        super()
        @parent = parent
        @type = obj[:type]
        @name = obj[:name]
        @args = obj[:args]
        @doc = obj[:doc]
        @visibility = obj[:visibility]
        @overriden_by = nil
        @defined_by = FileRef.new(nil, filename, obj)
      end

      # Public: Marks this method as being overriden by a provided object in
      # a given filename. This method initializes a new DocMethod instance using
      # this instance's parent, the provided filename and object, and invokes
      # #override! on it.
      #
      # filename - The filename defining the override for this method
      # obj      - The object representing the override for this method
      def override(filename, obj)
        override! DocMethod.new(@parent, filename, obj)
      end

      # Public: Marks this method as being overriden by the provided method
      #
      # method - DocMethod object overriding this method's implementation
      def override!(method)
        @overriden_by = method
      end

      def inspect
        type = @type == :def ? "method" : "singleton method"
        overriden = overriden_by.nil? ? "" : " overriden"
        "#<DocMethod:#{format("0x%08x", object_id * 2)} #{visibility} #{type} #{name}#{overriden}>"
      end

      # Public: Returns a Hash representation of this method
      def to_h
        {
          type: type,
          name: name,
          args: args,
          doc: DocBlocks.prepare(doc, parent: self),
          visibility: visibility,
          overriden_by: overriden_by,
          defined_by: defined_by&.to_h
        }
      end
    end
  end
end

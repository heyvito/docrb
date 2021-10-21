module Docrb
  class DocCompiler
    class DocAttribute < Resolvable

      attr_reader :parent, :defined_by, :name, :docs, :type, :writer_visibility,
                  :reader_visibility

      def initialize(parent, filename, obj)
        @parent = parent
        @defined_by = [filename]
        @name = obj[:name]
        @docs = obj[:docs]
        @type = nil
        @writer_visibility = obj[:writer_visibility]
        @reader_visibility = obj[:reader_visibility]
      end

      def accessor!
        @type = :accessor
        self
      end

      def reader!
        @type = :reader
        self
      end

      def writer!
        @type = :writer
        self
      end

      def to_h
        {
          defined_by: defined_by,
          name: name,
          docs: docs,
          type: type,
          writer_visibility: writer_visibility,
          reader_visibility: reader_visibility,
        }
      end
    end
  end
end

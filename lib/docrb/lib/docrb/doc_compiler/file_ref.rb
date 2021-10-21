# frozen_string_literal: true

module Docrb
  class DocCompiler
    # FileRef represents a file reference. This class is used to represent
    # definition metadata of objects in files. Instances of this class
    # indicates filenames and boundaries for a represented object.
    class FileRef
      attr_reader :filename, :start_at, :end_at

      # Initializes a new FileRef instance.
      #
      # _parent  - Unused.
      # filename - Path to the file being referenced
      # obj      - The object being referenced in the provided filename
      #
      def initialize(_parent, filename, obj)
        @filename = filename
        @start_at, @end_at = obj.values_at(:start_at, :end_at)
      end

      # Public: Returns the source code portion of the represented reference
      def ruby_source
        f = File.read(filename).split("\n")[start_at - 1..end_at - 1]
        f.join("\n")
      end

      # Public: Returns the reference's Hash representation
      def to_h
        source = ruby_source
        {
          filename: filename,
          start_at: start_at,
          end_at: end_at,
          source: source,
          markdown_source: Markdown.render_source(source)
        }
      end
    end
  end
end

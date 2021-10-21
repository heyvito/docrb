module Docrb
  class DocCompiler
    class FileRef
      attr_reader :filename, :start_at, :end_at
      def initialize(_parent, filename, obj)
        @filename = filename
        @start_at, @end_at = obj.values_at(:start_at, :end_at)
      end

      def ruby_source
        f = File.read(filename).split("\n")[start_at - 1..end_at - 1]
        f.join("\n")
      end

      def to_h
        source = ruby_source
        {
          filename: filename,
          start_at: start_at,
          end_at: end_at,
          source: source,
          markdown_source: Markdown.render_source(source),
        }
      end
    end
  end
end

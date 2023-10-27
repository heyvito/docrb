class Renderer
  class Template
    class Bind
      def initialize(obj, **keys)
        @obj = obj
        @keys = keys
      end

      def method_missing(method_name, ...)
        if @keys.include? method_name
          @keys[method_name]
        else
          @obj.send(method_name, ...)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @keys.key?(method_name.to_s) || @obj.respond_to_missing?(method_name, include_private)
      end

      def make_binding
        binding
      end
    end

    def initialize(path)
      @template = ERB.new(File.read(path))
      @template.filename = path.to_s
    end

    def render(bin, *, **)
      bind = Bind.new(bin, *, **)
      @template.result(bind.make_binding)
    end
  end
end

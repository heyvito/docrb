module Docrb
  class DocCompiler
    class ObjectContainer
      extend Forwardable

      attr_reader :objects

      def initialize(parent, cls, **opts)
        @cls = cls
        @objects = []
        @opts = opts
        @parent = parent
      end

      def_delegators :@objects, :length, :each, :map, :find, :filter, :first, :[], :to_json

      def push(filename, obj)
        if @cls.method_defined?(:name) &&
           (instance = @objects.find { |o| o.name == obj[:name] }) &&
           !@opts.fetch(:always_append, false)
          if instance.respond_to? :merge
            return instance.merge(filename, obj)
          elsif instance.respond_to? :override
            return instance.override(filename, obj)
          elsif instance.respond_to? :append
            return instance.append(filename, obj)
          end
          raise ArgumentError, "cannot handle existing object #{obj[:name]} for container of type #{@cls.name}"
        end

        inst = @cls.new(@parent, filename, obj)
        @objects << inst
        inst
      end

      def inspect
        opts = []
        opts << "always_append" if @opts[:always_append]
        count = if @objects.count == 0
          "empty"
        else
          "#{@objects.length} object#{@objects.length != 1 ? "s" : ""}"
        end

        "#<ObjectContainer:#{format("0x%08x", object_id * 2)} containing #{@cls.name}, #{count}#{opts.empty? ? "" : " #{opts.join(", ")}"}>"
      end
    end
  end
end

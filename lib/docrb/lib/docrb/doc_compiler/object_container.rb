# frozen_string_literal: true

module Docrb
  class DocCompiler
    # ObjectContainer implements utilities for representing a container of
    # objects with a common type.
    class ObjectContainer
      extend Forwardable

      attr_reader :objects

      # Initializes a new container with a given parent, containing objects with
      # a provided class and options.
      #
      # parent - The container's parent
      # cls    - The class of represented items
      # **opts - Options list. Currently, only `always_append` is supported,
      #          which indicates that all objects provided to the instance must
      #          be appended regardless of their type.
      def initialize(parent, cls, **opts)
        @cls = cls
        @objects = []
        @opts = opts
        @parent = parent
      end

      def_delegators :@objects, :length, :each, :map, :find, :filter, :first, :[], :to_json

      # Pushes a new object into the container. May raise ArgumentError in case
      # the object being pushed is not compatible with the container's base
      # object.
      #
      # filename - Name of the file which defines the object being pushed
      # obj      - The object being pushed
      #
      # Returns the new instance representing the pushed object.
      def push(filename, obj)
        if @cls.method_defined?(:name) &&
           (instance = @objects.find { |o| o.name == obj[:name] }) &&
           !@opts.fetch(:always_append, false)

          return instance.merge(filename, obj) if instance.respond_to? :merge
          return instance.override(filename, obj) if instance.respond_to? :override
          return instance.append(filename, obj) if instance.respond_to? :append

          raise ArgumentError, "cannot handle existing object #{obj[:name]} for container of type #{@cls.name}"
        end

        inst = @cls.new(@parent, filename, obj)
        @objects << inst
        inst
      end

      def inspect
        opts = []
        opts << "always_append" if @opts[:always_append]
        count = if @objects.count.zero?
                  "empty"
                else
                  "#{@objects.length} object#{@objects.length == 1 ? "" : "s"}"
                end
        obj_id = format("0x%08x", object_id * 2)
        opts_repr = opts.empty? ? "" : " #{opts.join(", ")}"
        "#<ObjectContainer:#{obj_id} containing #{@cls.name}, #{count}#{opts_repr}>"
      end
    end
  end
end

# frozen_string_literal: true

module Docrb
  class DocCompiler
    # BaseContainer represents a container for methods, classes, modules and
    # attributes.
    class BaseContainer < Resolvable
      require_relative "./base_container/computations"
      include Computations

      attr_accessor :extends, :includes, :classes, :modules, :defs, :sdefs,
                    :type, :name, :defined_by, :parent, :doc

      # Initialises a new BaseContainer instance with a provided parent,
      # filename and represented object.
      def initialize(parent, filename, obj)
        super()
        @parent = parent
        @type = obj[:type]
        @name = obj[:name]
        @extends = []
        @includes = []
        @classes = ObjectContainer.new(self, DocClass)
        @modules = ObjectContainer.new(self, DocModule)
        @defs = ObjectContainer.new(self, DocMethod)
        @sdefs = ObjectContainer.new(self, DocMethod)
        @defined_by = ObjectContainer.new(nil, FileRef)
        append(filename, obj)
      end

      # Appends a new object defined by the provided file to this container
      def <<(filename, obj)
        append(filename, obj)
      end

      # Appends a new class defined by the provided file to this container
      def append_class(filename, cls)
        @classes.push filename, cls
      end

      def inspect
        ext = "#{extends.length} extend#{extends.length == 1 ? "" : "s"}"
        inc = "#{includes.length} include#{includes.length == 1 ? "" : "s"}"
        cls = "#{classes.length} class#{classes.length == 1 ? "" : "es"}"
        mod = "#{modules.length} module#{modules.length == 1 ? "" : "s"}"
        de = "#{defs.length} def#{defs.length == 1 ? "" : "s"}"
        sde = "#{sdefs.length} sdef#{sdefs.length == 1 ? "" : "s"}"

        "#<#{self.class.name}:#{format("0x%08x",
                                       object_id * 2)} #{@type} #{@name} #{ext}, #{inc}, #{cls}, #{mod}, #{de}, #{sde}>"
      end

      # Attempts to append a given object defined in a provided filename.
      # Raises ArgumentError in case the object can't be added to the container
      # due to type contraints.
      #
      # filename - Filename defining the object being appended
      # obj      - The object definition to be appended to this container.
      def append(filename, obj)
        raise ArgumentError, "cannot append obj of type #{obj[:type]} into #{@name} (#{@type})" if obj[:type] != @type

        raise ArgumentError, "cannot append obj named #{obj[:name]} into #{@name} (#{@type})" if obj[:name] != @name

        unless (doc = obj[:doc]).nil?
          @defined_by.push(filename, obj)
          @doc = doc
        end

        obj.fetch(:classes, []).each { |c| @classes.push(filename, c) }
        obj.fetch(:modules, []).each { |m| @modules.push(filename, m) }
        obj.fetch(:extend, []).each { |e| @extends << e }
        obj.fetch(:include, []).each { |i| @includes << i }
        obj.fetch(:methods, []).each do |met|
          if met[:type] == :def
            @defs.push(filename, met)
          else
            @sdefs.push(filename, met)
          end
        end

        @inherits = obj.fetch(:inherits, nil) if obj[:type] == :class

        appended(filename, obj)
      end

      # Courtesy method. This method is called whenever a new object is
      # appended to the container. Inheriting classes can override it to perform
      # further operations on the appended object.
      def appended(filename, obj); end

      # Intenral: Recursively unpacks a given element by checking its
      # :definition and :overriding keys.
      #
      # Returns the updated element.
      def unpack(elem)
        return unless elem

        elem.tap do |e|
          inner = e[:definition]
          e[:definition] = inner.is_a?(Hash) ? unpack(inner) : inner.to_h
          e[:overriding] = unpack(e[:overriding])
        end
      end

      # Returns a Hash representation of the current container along with its
      # children.
      def to_h
        {
          type:,
          name:,
          doc: DocBlocks.prepare(doc, parent: self),
          defined_by: defined_by.map(&:to_h),
          defs: merged_instance_methods.transform_values { |v| unpack(v) },
          sdefs: merged_class_methods.transform_values { |v| unpack(v) },
          classes: classes.map(&:to_h),
          modules: modules.map(&:to_h),
          includes: includes.map(&:to_h),
          extends: extends.map(&:to_h)
        }
      end
    end
  end
end

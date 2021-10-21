module Docrb
  class DocCompiler
    class BaseContainer < Resolvable
      require_relative './base_container/computations'
      include Computations

      attr_accessor :extends, :includes, :classes, :modules, :defs, :sdefs,
                    :type, :name, :defined_by, :parent, :doc

      def initialize(parent, filename, obj)
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

      def <<(filename, obj)
        append(filename, obj)
      end

      def append_class(filename, cls)
        @classes.push filename, cls
      end

      def inspect
        ext = "#{extends.length} extend#{extends.length != 1 ? "s" : ""}"
        inc = "#{includes.length} include#{includes.length != 1 ? "s" : ""}"
        cls = "#{classes.length} class#{classes.length != 1 ? "es" : ""}"
        mod = "#{modules.length} module#{modules.length != 1 ? "s" : ""}"
        de = "#{defs.length} def#{defs.length != 1 ? "s" : ""}"
        sde = "#{sdefs.length} sdef#{sdefs.length != 1 ? "s" : ""}"

        "#<#{self.class.name}:#{format("0x%08x", object_id * 2)} #{@type} #{@name} #{ext}, #{inc}, #{cls}, #{mod}, #{de}, #{sde}>"
      end

      def append(filename, obj)
        if obj[:type] != @type
          raise ArgumentError, "cannot append obj of type #{obj[:type]} into #{@name} (#{@type})"
        end

        if obj[:name] != @name
          raise ArgumentError, "cannot append obj named #{obj[:name]} into #{@name} (#{@type})"
        end

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

        if obj[:type] == :class
          @inherits = obj.fetch(:inherits, nil)
        end

        appended(filename, obj)
      end

      def appended(filename, obj); end

      def unpack(el)
        return unless el
        el.tap do |e|
          inner = e[:definition]
          e[:definition] = inner.is_a?(Hash) ? unpack(inner) : inner.to_h
          e[:overriding] = unpack(e[:overriding])
        end
      end

      def to_h
        {
          type: type,
          name: name,
          doc: DocBlocks.prepare(doc, parent: self),
          defined_by: defined_by.map(&:to_h),
          defs: merged_instance_methods.map { |k, v| [k, unpack(v)] }.to_h,
          sdefs: merged_class_methods.map { |k, v| [k, unpack(v)] }.to_h,
          classes: classes.map(&:to_h),
          modules: modules.map(&:to_h),
          includes: includes.map(&:to_h),
          extends: extends.map(&:to_h)
        }
      end
    end
  end
end

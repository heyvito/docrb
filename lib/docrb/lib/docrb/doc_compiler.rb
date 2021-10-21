module Docrb
  class DocCompiler < Resolvable
    autoload :FileRef, "docrb/doc_compiler/file_ref"
    autoload :BaseContainer, "docrb/doc_compiler/base_container"
    autoload :DocClass, "docrb/doc_compiler/doc_class"
    autoload :DocModule, "docrb/doc_compiler/doc_module"
    autoload :DocMethod, "docrb/doc_compiler/doc_method"
    autoload :DocAttribute, "docrb/doc_compiler/doc_attribute"
    autoload :ObjectContainer, "docrb/doc_compiler/object_container"
    autoload :DocBlocks, "docrb/doc_compiler/doc_blocks"

    attr_reader :classes, :modules, :methods, :parent

    def initialize
      @classes = ObjectContainer.new(self, DocClass)
      @modules = ObjectContainer.new(self, DocModule)
      @methods = ObjectContainer.new(self, DocMethod)
      @parent = nil
    end

    def append(obj)
      filename = obj[:filename]
      target = case obj[:type]
      when :module
        @modules
      when :class
        @classes
      when :def, :defs
        @methods
      else
        nil
      end

      if target.nil?
        raise ArgumentError, "cannot append obj of type #{obj[:type]}"
      end

      target.push(filename, obj)
    end

    def to_h
      {
        modules: @modules.map(&:to_h),
        classes: @classes.map(&:to_h),
        methods: @methods.map(&:to_h),
      }
    end
  end
end

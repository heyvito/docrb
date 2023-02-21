# frozen_string_literal: true

class Renderer
  class Defs
    class SpecializedObject
      def initialize(obj, parent, provider)
        @obj = obj
        @provider = provider
        prepare(parent)
      end

      def self.specialize(obj, parent, provider)
        return nil if obj.nil?

        new(obj, parent, provider)
      end

      def [](key) = @obj[key]
      def fetch(*, **, &) = @obj.fetch(*, **, &)

      def resolve(name)
        named = named_as(name)
        modules.find(&named) \
        || classes.find(&named) \
        || attributes&.find(&named) \
        || defs.find(&named) \
        || sdefs.find(&named)
      end

      def resolve_inheritance(name)
        named = named_as(name)
        modules.find(&named) \
        || classes.find(&named) \
        || parent&.resolve_inheritance(name)
      end

      def resolve_parent(name)
        parent = self[:parent]
        return { type: "Unknown Ref", name: } unless parent

        parent.resolve(name) || parent.resolve_parent(name)
      end

      def resolve_path(path)
        p = path.dup
        obj = self
        until p.empty?
          obj = obj.resolve(p[0])
          return unless obj

          p.shift
        end
        obj
      end

      def resolve_qualified(obj)
        result = nil
        query = nil

        if obj[:class_path]&.length&.> 0
          query = obj[:class_path] + [obj[:name]]
          result = root.resolve_path(query)
        else
          query = obj[:name]
          result = resolve(query)
          result ||= resolve_inheritance(query)
        end

        puts "Qualified resolution of #{query.inspect} by #{name} failed." unless result

        result
      end

      def method_missing(method_name, *args, **kwargs, &)
        var = "@#{method_name}".to_sym
        if instance_variables.include?(var)
          instance_variable_get(var)
        elsif @obj.key? method_name
          @obj.fetch(method_name)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        instance_variables.include?("@#{method_name}".to_sym) || @obj.key?(method_name) || super
      end

      def to_s
        "<SpecializedObject for #{@provider.path_of(@obj).join("::")}>"
      end

      def inspect = to_s

      def prepare_inheritance
        @inheritance_prepared = true
        @inherits = coerce_inheritance_data(@obj[:inherits])
        @extends = @obj[:extends]&.map { resolve_qualified _1 }
        @includes = @obj[:includes]&.map { resolve_qualified _1 }
        @classes.each(&:prepare_inheritance)
        @modules.each(&:prepare_inheritance)
      end

      private

      def make_path
        r = [name]
        p = parent
        while p
          r << p.name
          p = p.parent
        end

        r.reverse
      end

      def parent_of(parent)
        return unless parent

        p = parent
        while p
          return p unless p.parent

          p = p.parent
        end

        p
      end

      def specialize_defs(defs, _parent)
        defs.values.map do |i|
          decoration = if i[:source] == "inheritance"
                         "inherited"
                       elsif i[:overriding]
                         "override"
                       else
                         ""
                       end

          origin = i[:source]

          @provider.find_source(i)
                   .merge({ decoration:, origin: })
        end
      end

      def coerce_inheritance_data(obj)
        return obj if obj.nil?

        resolve_inheritance(obj) || obj
      end

      def prepare(parent)
        @inheritance_prepared = true
        @parent = parent
        @defs = specialize_defs(@obj[:defs], self)
        @sdefs = specialize_defs(@obj[:sdefs], self)
        @attributes = (@obj[:attributes] || {}).values.map do |v|
          @provider.prepare_attr(v)
        end

        @root = parent_of(parent)
        @path = make_path

        @classes = @obj[:classes].map { SpecializedObject.specialize(_1, self, @provider) }
        @modules = @obj[:modules].map { SpecializedObject.specialize(_1, self, @provider) }
      end

      def named_as(n) = ->(o) { o.name == n }
    end
  end
end

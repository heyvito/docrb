module Docrb
  class Resolvable
    def by_name(name)
      lambda { |obj| obj.name == name }
    end

    def by_name_and_type(name, type)
      lambda { |obj| obj.name == name && obj.type == type }
    end

    def resolve_method(name)
      if (local = self.try?(:defs)&.find(&by_name(name)))
        return local
      end

      if (local = self.try?(:sdefs)&.find(&by_name(name)))
        return local
      end

      # Inherited?
      if (inherited = self.try?(:inherits)&.try?(:resolve_method, name, type))
        return inherited
      end

      nil
    end

    def resolve_container(ref)
      if ref.is_a? Hash
        path = ref
          .slice(:class_path, :target, :name)
          .values
          .flatten
          .compact
        return resolve_container(path)
      end

      if ref.length == 1
        name = ref.first
        # module?
        if (mod = self.try?(:modules)&.find(&by_name(name)))
          return mod
        end

        # class?
        if (cls = self.try?(:classes)&.find(&by_name(name)))
          return cls
        end

        # parent?
        return @parent&.resolve_container(ref)
      end

      obj = self
      while ref.length > 0
        obj = self.resolve_container(ref.shift)
        return nil if obj.nil?
      end
      obj
    end

    def resolve(name)
      return nil if name.nil?

      # module?
      if (mod = self.try?(:modules)&.find(&by_name(name)))
        return mod
      end

      # class?
      if (cls = self.try?(:classes)&.find(&by_name(name)))
        return cls
      end

      # method?
      if (met = resolve_method(name))
        return met
      end

      # attribute?
      if (att = self.try?(:attributes)&.find(&by_name(name)))
        return att
      end

      if (obj = @parent&.resolve(name))
        return obj
      end

      nil
    end

    def resolve_ref(ref)
      path = ref
        .slice(:class_path, :target, :name)
        .values
        .flatten
        .compact
        .join("::")
      resolve_qualified(path)
    end

    def resolve_qualified(path)
      components = path.split("::").map(&:to_sym)
      obj = root
      until components.empty?
        obj = obj.resolve(components.shift)
        break if obj.nil?
      end
      obj
    end

    def root
      obj = self
      while obj.parent
        obj = obj.parent
      end
      obj
    end

    def path
      return [] if parent.nil?
      parent.path + [name]
    end
  end
end

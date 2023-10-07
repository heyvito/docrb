# frozen_string_literal: true

module Docrb
  # Resolvable implements utilities for resolving names and class paths on a
  # container context (module/class)
  class Resolvable
    # Returns a matcher for a provided name
    #
    # name - Name to match against
    def by_name(name)
      ->(obj) { obj.name == name }
    end

    # Returns a matcher for a provided name and type
    #
    # name - Name to match against
    # type - Object type to match against (:def/:sdef/:class/:module...)
    def by_name_and_type(name, type)
      ->(obj) { obj.name == name && obj.type == type }
    end

    # Attempts to resolve a method with a provided name in the container's
    # context. This method attempts to match for instance methods, class
    # methods, and finally by recursively calling this method on the inherited
    # members, if any.
    #
    # name - Name of the method to be resolved.
    #
    # Returns a method structure, or nil, in case none is found.
    def resolve_method(name)
      if (local = try?(:defs)&.find(&by_name(name)))
        return local
      end

      if (local = try?(:sdefs)&.find(&by_name(name)))
        return local
      end

      # Inherited?
      if (inherited = try?(:inherits)&.try?(:resolve_method, name, type))
        return inherited
      end

      nil
    end

    # Resolves a container using a provided reference.
    #
    # ref - Either a reference hash (containing :class_path, :target, :name), or
    #       a symbol representing the name of the container being resolved.
    #
    # Returns a matched container or nil, in case none is found.
    def resolve_container(ref)
      if ref.is_a? Hash
        path = ref
               .slice(:class_path, :target, :name)
               .values
               .flatten
               .compact
        return resolve_container(path)
      end

      ref = [ref] if ref.is_a? Symbol

      if ref.length == 1
        name = ref.first
        # module?
        if (mod = try?(:modules)&.find(&by_name(name)))
          return mod
        end

        # class?
        if (cls = try?(:classes)&.find(&by_name(name)))
          return cls
        end

        # parent?
        return @parent&.resolve_container(ref)
      end

      obj = self
      while ref.length.positive?
        obj = resolve_container(ref.shift)
        return nil if obj.nil?
      end

      obj
    end

    # Resolves a provided name in the current containter's context. This method
    # will attempt to return an object matching the provided name by looking for
    # it in the following subcontainers: modules, classes, methods, attributes,
    # and recursively performing the resolution on the container's parent, if
    # any.
    #
    # name - Name of the object being resolved
    #
    # Returns the first object found by the provided name, or nil, in case none
    # is found.
    def resolve(name)
      return nil if name.nil?

      name = name.to_sym

      # module?
      if (mod = try?(:modules)&.find(&by_name(name)))
        return mod
      end

      # class?
      if (cls = try?(:classes)&.find(&by_name(name)))
        return cls
      end

      # method?
      if (met = resolve_method(name))
        return met
      end

      # attribute?
      if (att = try?(:attributes)&.find(&by_name(name)))
        return att
      end

      if (obj = @parent&.resolve(name))
        return obj
      end

      nil
    end

    # Resolves a provided ref by creating its path string representation and
    # calling #resolve_qualified
    #
    # ref - Hash representing the reference being resolved.
    #
    # Returns the object under the provided reference, or nil.
    def resolve_ref(ref)
      path = ref
             .slice(:class_path, :target, :name)
             .values
             .flatten
             .compact
      return resolve_qualified(path.join("::")) if path.length > 1

      resolve(path[0])
    end

    # Resolves a qualified path under the current container's context.
    #
    # path - Path of the object being resolved. Must be a string containing the
    #        object name being searched, or a classpath for it (e.g.
    #        `Foo::Bar::Baz`)
    def resolve_qualified(path)
      components = path.is_a?(Array) ? path : path.split("::").map(&:to_sym)
      components.shift if components&.first == "::"

      obj = root
      until components.empty?
        obj = obj.resolve(components.shift)
        break if obj.nil?
      end
      obj
    end

    # Returns the root object for the current container
    def root
      obj = self
      obj = obj.parent while obj.parent
      obj
    end

    # Returns the container's full qualified path
    def path
      return [] if parent.nil?

      parent.path + [name]
    end
  end
end

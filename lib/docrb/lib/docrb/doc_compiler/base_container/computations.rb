# frozen_string_literal: true

module Docrb
  class DocCompiler
    class BaseContainer
      # Module Computations implements utility methods to handle hierarchy and
      # nesting.
      module Computations
        # Recursively computes all dependants of the receiver.
        # This method expands all references into concrete representations.
        def compute_dependants
          return if @compute_dependants

          @compute_dependants = true

          classes.each(&:compute_dependants)
          modules.each(&:compute_dependants)

          extends.each do |ref|
            resolve_ref(ref)&.compute_dependants
          end
          includes.each do |ref|
            resolve_ref(ref)&.compute_dependants
          end

          return unless (parent_name = @inherits)

          @parent_class = resolve(parent_name)
          return unless @parent_class

          @parent_class.compute_dependants
        end

        # Returns a Hash containing all methods for the container, along with
        # inherited and included ones.
        def merged_instance_methods
          return @merged_instance_methods if @merged_instance_methods

          compute_dependants

          methods = {}
          @parent_class&.merged_instance_methods&.each do |k, v|
            methods[k] = { source: :inheritance, definition: v }
          end

          includes.each do |ref|
            next unless (container = resolve_container(ref))

            container.merged_instance_methods.each do |k, v|
              methods[k] = { source: :inclusion, definition: v, overriding: methods[k] }
            end
          end

          defs.each do |m|
            methods[m.name] = { source: :source, definition: m, overriding: methods[m.name] }
          end

          methods
        end

        # Returns a hash containing all class methods for the container, along
        # with inherited and extended ones.
        def merged_class_methods
          return @merged_class_methods if @merged_class_methods

          compute_dependants

          methods = {}
          @parent_class&.merged_class_methods&.each do |k, v|
            methods[k] = { source: :inheritance, definition: v }
          end

          includes.each do |ref|
            next unless (container = resolve_container(ref))

            container.merged_class_methods.each do |k, v|
              methods[k] = { source: :extension, definition: v, overriding: methods[k] }
            end
          end

          sdefs.each do |m|
            methods[m.name] = { source: :source, definition: m, overriding: methods[m.name] }
          end

          methods
        end

        # Returns a hash containing all attributes for the container, along with
        # inherited ones.
        def merged_attributes
          return @merged_attributes if @merged_attributes

          compute_dependants

          attrs = {}
          @parent_class&.merged_attributes&.each do |k, v|
            attrs[k] = { source: :inheritance, definition: v }
          end

          attributes.each do |m|
            attrs[m.name] = { source: :source, definition: m, overriding: attrs[m.name] }
          end

          attrs
        end

        # Deprecated: Use #merged_instance_methods.
        def all_defs
          return @all_defs if @all_defs

          compute_dependants

          methods = {}
          @parent_class&.all_defs&.each do |k, v|
            methods[k] = v
          end

          includes.each do |ref|
            resolve_ref(ref)&.all_defs&.each do |met|
              if methods.key? met.name
                methods[key].override! met
                next
              end

              methods[met.name] = met
            end
          end

          defs.each do |met|
            if methods.key? met.name
              methods[met.name].override! met
              next
            end

            methods[met.name] = met
          end

          @all_defs = methods
        end

        # Deprecated: Use #merged_class_methods.
        def all_sdefs
          return @all_sdefs if @all_sdefs

          compute_dependants

          methods = {}

          @parent_class&.all_sdefs&.each do |k, v|
            methods[k] = v
          end

          extends.each do |ref|
            resolve_ref(ref)&.all_defs&.each do |met|
              if methods.key? met.name
                methods[met.name].override! met
                next
              end

              methods[met.name] = met
            end
          end

          @sdefs.each do |met|
            if methods.key? met.name
              methods[met.name].override! met
              next
            end

            methods[met.name] = met
          end

          @all_sdefs = methods
        end
      end
    end
  end
end

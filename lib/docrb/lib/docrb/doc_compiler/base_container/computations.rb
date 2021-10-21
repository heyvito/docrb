module Docrb
  class DocCompiler
    class BaseContainer
      module Computations
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

        def merged_instance_methods
          return @merged_instance_methods if @merged_instance_methods
          compute_dependants

          methods = {}
          if @parent_class
            @parent_class.merged_instance_methods.each do |k, v|
              methods[k] = { source: :inheritance, definition: v }
            end
          end

          includes.each do |ref|
            if (container = self.resolve_container(ref))
              container.merged_instance_methods.each do |k, v|
                methods[k] = { source: :inclusion, definition: v, overriding: methods[k] }
              end
            end
          end

          defs.each do |m|
            methods[m.name] = { source: :source, definition: m, overriding: methods[m.name] }
          end

          methods
        end

        def merged_class_methods
          return @merged_class_methods if @merged_class_methods
          compute_dependants

          methods = {}
          if @parent_class
            @parent_class.merged_class_methods.each do |k, v|
              methods[k] = { source: :inheritance, definition: v }
            end
          end

          includes.each do |ref|
            if (container = self.resolve_container(ref))
              container.merged_class_methods.each do |k, v|
                methods[k] = { source: :extension, definition: v, overriding: methods[k] }
              end
            end
          end

          sdefs.each do |m|
            methods[m.name] = { source: :source, definition: m, overriding: methods[m.name] }
          end

          methods
        end

        def merged_attributes
          return @merged_attributes if @merged_attributes
          compute_dependants

          attrs = {}
          if @parent_class
            @parent_class.merged_attributes.each do |k, v|
              attrs[k] = { source: :inheritance, definition: v }
            end
          end

          attributes.each do |m|
            attrs[m.name] = { source: :source, definition: m, overriding: attrs[m.name] }
          end

          attrs
        end

        def all_defs
          return @all_defs if @all_defs

          compute_dependants

          methods = {}
          if @parent_class
            @parent_class.all_defs.each do |k, v|
              methods[k] = v
            end
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

        def all_sdefs
          return @all_sdefs if @all_sdefs

          compute_dependants

          methods = {}

          if @parent_class
            @parent_class.all_sdefs.each do |k, v|
              methods[k] = v
            end
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

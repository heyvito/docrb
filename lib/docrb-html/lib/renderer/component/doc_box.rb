# frozen_string_literal: true

class Renderer
  class Component
    class DocBox < Component
      prop :item, :meta, :has_class_docs, :has_class_details,
           :instance_methods, :has_instance_methods,
           :class_methods, :has_class_methods,
           :has_instance_attributes, :instance_attributes,
           :has_class_attributes, :class_attributes,
           :has_constants, :constants,
           :page_components

      def prepare
        @has_class_docs = (item.doc && !item.doc.empty?) || false
        @instance_methods = item.all_instance_methods
        @class_methods = item.all_class_methods
        @instance_attributes = item.kind == :class ? item.all_instance_attributes : []
        @class_attributes = item.all_class_attributes
        @constants = item.constants

        @has_instance_attributes = !@instance_attributes.empty?
        @has_class_attributes = !@class_attributes.empty?
        @has_class_methods = !@class_methods.empty?
        @has_instance_methods = !@instance_methods.empty?
        @has_class_details =
          (item.kind == :class && !item.inherits.nil?) \
            || !item.extends.empty? \
            || !item.includes.empty? \
            || !item.modules.empty? \
            || !item.classes.empty?
        @has_constants = !@constants.empty?

        @page_components = {
          "class-documentation" => { enabled: has_class_docs, name: "Class Documentation" },
          "class-details" => { enabled: has_class_details, name: "Inheritance" },
          "constants" => { enabled: has_constants, name: "Constants" },
          "attributes" => { enabled: has_class_attributes || has_instance_attributes, name: "Attributes" },
          "class-methods" => { enabled: has_class_methods, name: "Class Methods" },
          "instance-methods" => { enabled: has_instance_methods, name: "Instance Methods" }
        }
      end
    end
  end
end

# frozen_string_literal: true

class Renderer
  class Component
    class DocBox < Component
      prop :item, :meta, :defs, :has_class_docs, :has_class_details, :has_attrs,
           :has_class_methods, :has_instance_methods, :page_components,
           :defs, :sdefs, :attrs

      def prepare
        @item = defs.specialized_projection.find_path(@item)

        @has_class_docs = item[:doc] && !item[:doc].empty?
        @defs = item.defs || []
        @sdefs = item.sdefs || []
        @attrs = item.attributes || []

        @has_attrs = !@attrs.empty?
        @has_class_methods = !@sdefs.empty?
        @has_instance_methods = !@defs.empty?
        @has_class_details =
          !item[:inherits].nil? \
          || !item.fetch(:extends, []).empty? \
          || !item.fetch(:includes, []).empty? \
          || !item.fetch(:modules, []).empty? \
          || !item.fetch(:classes, []).empty?

        @page_components = {
          "class-documentation" => { enabled: has_class_docs, name: "Class Documentation" },
          "class-details" => { enabled: has_class_details, name: "Inheritance" },
          "attributes" => { enabled: has_attrs, name: "Attributes" },
          "class-methods" => { enabled: has_class_methods, name: "Class Methods" },
          "instance-methods" => { enabled: has_instance_methods, name: "Instance Methods" }
        }
      end
    end
  end
end

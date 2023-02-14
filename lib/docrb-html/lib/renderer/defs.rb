# frozen_string_literal: true

require_relative "defs/specialized_object"
require_relative "defs/specialized_projection"

class Renderer
  class Defs
    class << self
      attr_reader :singleton
    end

    class << self
      attr_writer :singleton
    end

    def initialize(base, metadata)
      @data = JSON.parse(File.read("#{base}/data.json"), symbolize_names: true)
      @meta = metadata
      Defs.singleton = self
    end

    attr_reader :meta

    def classes = @classes ||= make_paths(@data[:classes])
    def modules = @modules ||= make_paths(@data[:modules])

    def make_paths(obj)
      return [] unless obj

      obj.each { set_parent(_1, nil) }
    end

    def set_parent(obj, parent)
      obj[:parent] = parent
      obj[:classes].each { set_parent(_1, obj) }
      obj[:modules].each { set_parent(_1, obj) }
    end

    def document_outline
      (classes + modules).map { outline(_1) }
    end

    def outline(object, level = 0)
      defs = object[:defs].values.map { map_method(_1) }.sort_by { _1[:name] }
      sdefs = object[:sdefs].values.map { map_method(_1) }.sort_by { _1[:name] }
      attributes = object[:attributes]&.values&.map { prepare_attr(_1) }&.sort_by { _1[:name] }

      {
        level:,
        name: object[:name],
        type: object[:type],
        classes: object[:classes].map { outline(_1, level + 1) },
        modules: object[:modules].map { outline(_1, level + 1) },
        defs: defs + sdefs,
        attributes:
      }
    end

    def map_method(met)
      decoration = if met[:source] == "inheritance"
                     "inherited"
                   elsif met[:overriding]
                     "override"
                   end

      obj = find_source(met)
      type = [].tap do |arr|
        arr << "Class" if obj[:type] == "defs"
        arr << "Method"
      end.join(" ")

      {
        name: obj[:name],
        visibility: obj[:visibility],
        args: obj[:args],
        type:,
        short_type: obj[:type],
        doc: obj[:doc],
        decoration:
      }
    end

    def find_source(met)
      obj = met
      obj = obj[:definition] while obj[:source] != "source"
      obj[:definition]
    end

    def prepare_attr(met)
      decoration = if met[:source] == "inheritance"
                     "inherited"
                   elsif met[:overriding]
                     "override"
                   end
      origin = met[:source]
      att = find_source(met)
      visibility = if att[:reader_visibility] == "public" && att[:writer_visibility] == "public"
                     "read/write"
                   elsif att[:reader_visibility] == "public" && att[:writer_visibility] != "public"
                     "read-only"
                   else
                     "write-only"
                   end

      {
        name: att[:name],
        type: "Attribute",
        visibility:,
        decoration:,
        origin:,
        doc: att[:doc]
      }
    end

    def path_of(item)
      p = []
      parent = item
      until parent.nil?
        p << parent[:name]
        parent = parent[:parent]
      end
      p.reverse
    end

    def definitions_of(item)
      item[:defined_by]&.map do |d|
        path_components = d[:filename].split("/")
        {
          name: path_components.last,
          href: git_url(d)
        }
      end
    end

    def git_url(definition)
      "#{@meta.git_url}/blob/#{@meta.git_tip}#{definition[:filename].gsub(@meta.git_root,
                                                                          "")}#L#{definition[:start_at]}"
    end

    def clean_file_path(definition) = definition[:filename].gsub(meta.git_root, "")

    def specialized_projection
      @specialized_projection ||= SpecializedProjection.new(self)
    end

    def specialize_data
      @specialize_data ||= (data[:modules] + data[:classes])
                           .map { specialize_object _1 }
                           .each(&:prepare_inheritance)
    end

    def specialize_object(obj, parent = nil)
      SpecializedObject.specialize(obj, parent, self)
    end

    def by_name(n) = ->(o) { o[:name] == n }

    def doc_for(path)
      path = path_of(path) if path.is_a? Hash
      path = path.dup
      named = by_name(path.shift)
      root = classes.find(&named) || modules.find(&named)

      return unless root

      find_recursive(path, root)
    end

    def find_recursive(path, root)
      return root if path.empty?

      named = by_name(path.shift)
      next_item = root.classes.find(&named) || root.modules.find(&named)

      return nil unless next_item

      find_recursive(path, next_item)
    end
  end
end

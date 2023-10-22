# frozen_string_literal: true

require "prism"

require_relative "parser/reloader"

require_relative "parser/version"
require_relative "core_extensions"
require_relative "parser/node_array"

require_relative "parser/method"
require_relative "parser/location"
require_relative "parser/method_parameters"
require_relative "parser/container"
require_relative "parser/class"
require_relative "parser/deferred_singleton_class"
require_relative "parser/module"
require_relative "parser/reference"
require_relative "parser/call"
require_relative "parser/attribute"
require_relative "parser/constant"
require_relative "parser/comment"

require_relative "parser/virtual_method"
require_relative "parser/virtual_location"
require_relative "parser/virtual_container"

require_relative "parser/resolved_reference"
require_relative "parser/computations"
require_relative "parser/comment_parser"

module Docrb
  class Parser
    attr_reader :current_file, :locations, :references, :nodes
    attr_accessor :debug, :ast_lines

    def initialize
      @current_ast = nil
      @current_file = nil
      @locations = []
      @references = []
      @ast_lines = {}
      @object_by_id = {}
      @current_object_id = 1
      @nodes = NodeArray.new
    end

    def lines_for(file, ast)
      return ast_lines[file] if ast_lines.key? file

      ast.source.source.split("\n").tap { ast_lines[file] = _1 }
    end

    def all_objects = @object_by_id.values
    def all_classes = all_objects.filter { _1.is_a? Class }
    def all_modules = all_objects.filter { _1.is_a? Module }
    def all_methods = all_objects.filter { _1.is_a? Method }


    def finalize = Computations.new(self).tap(&:run)

    docrb_inspect_attrs(:current_file, :locations, :references, :nodes)

    def parse(file)
      tap do
        @current_file = file
        @current_ast = Prism.parse_file(file)
        @nodes.append(*@current_ast.value.statements.body.map { handle_node(_1) }.reject { _1.is_a? Call })
      end
    end

    def make_id(obj)
      @current_object_id.tap do |id|
        @object_by_id[id] = obj
        @current_object_id += 1
      end
    end

    def object_by_id(id) = @object_by_id[id]

    def handle_node(node, parent = nil)
      case node.type
      when :def_node then Method.new(self, parent, node)
      when :class_node then Class.new(self, parent, node)
      when :module_node then Module.new(self, parent, node)
      when :singleton_class_node then handle_singleton_class(parent, node)
      when :call_node then Call.new(self, parent, node)
      when :constant_write_node then Constant.new(self, parent, node)
      else unhandled_node!(node)
      end
    end

    def unhandled_node!(node)
      return unless debug

      bs = caller_locations[1...].join("\n")
      type = node.try(:type) || node.class.name
      warn "Warning: Unhandled node type #{type}\n#{bs}\n#{node}"
    end

    def location(loc)
      return loc if loc.is_a? Location

      Location.new(self, @current_ast, loc).tap { @locations << _1 }
    end

    def reference(parent, path)
      raise ArgumentError, "Empty path" if path.nil? || path.empty?
      Reference.new(self, parent, path).tap { @references << _1 }
    end

    def attach_sources!
      @locations.each(&:load_source!)
    end

    def unfurl_constant_path(node)
      return [] unless node
      return [node.name] if node.type == :constant_read_node

      [].tap do |segments|
        while node&.type == :constant_path_node
          segments << node.child.name
          node = node.parent
        end
        segments << (node&.name || :root!)
        segments.reverse!
      end
    end

    def handle_singleton_class(parent, node)
      case node.expression.type
      when :self_node
        return Class.new(self, parent, node).tap(&:singleton!)
      else
        return DeferredSingletonClass.new(self, parent, node)
      end
    end
  end
end

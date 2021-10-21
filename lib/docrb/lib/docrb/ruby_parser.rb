module Docrb
  class RubyParser
    COMMENT_PREFIX = /^\s*#\s?/

    attr_reader :modules, :classes, :methods, :ast

    def initialize(path)
      @ast, @comments = ::Parser::CurrentRuby.parse_file_with_comments(path)
      @modules = []
      @classes = []
      @methods = []
    end

    def parse
      parse!(@ast)
      cleanup!
    end

    private

    def cleanup!
      clean_modules!
      clean_classes!
    end

    def parse!(node = nil, parent = nil)
      return if node.nil?
      case node.type
      when :def
        parse_def(node, parent)

      when :defs
        parse_singleton_method(node, parent)

      when :class
        parse_class(node, parent)

      when :sclass
        parse_singleton_class(node, parent)

      when :module
        parse_module(node, parent)

      when :begin
        parse_begin(node, parent)

      when :send
        parse_send(node, parent)

      end
    end

    def comment_for_line(line)
      return nil if line == 0 || line.negative?

      @comments.find { |c| c.loc.line == line }
    end

    def comments_from(line, type:)
      # First, find a comment for the line before this
      comments = []
      comment = comment_for_line(line)

      while comment
        comments << comment
        comment = comment_for_line(line - 1)
        line -= 1
      end

      return nil if comments.empty?

      comments = comments
        .collect(&:text)
        .collect { |l| l.gsub(COMMENT_PREFIX, "") }
        .reverse
        .join("\n")
      CommentParser.parse(type: type, comment: comments)
    end

    def parse_begin(node, parent)
      node.children.each { |n| parse!(n, parent) }
    end

    ATTRIBUTES = [:attr_reader, :attr_writer, :attr_accessor].freeze
    CLASS_MODIFIERS = [:extend, :include].freeze
    VISIBILITY_MODIFIERS = [:private, :protected, :public].freeze
    MODULE_MODIFIERS = [:module_function].freeze
    SEND_DISPATCH = {
      ATTRIBUTES => :parse_accessor,
      CLASS_MODIFIERS => :parse_class_modifier,
      VISIBILITY_MODIFIERS => :parse_visibility_modifier,
      MODULE_MODIFIERS => :parse_module_modifier,
    }.freeze

    PARSEABLE_SENDS = [*ATTRIBUTES, *CLASS_MODIFIERS, *VISIBILITY_MODIFIERS, *MODULE_MODIFIERS].freeze

    def parse_send(node, parent)
      arr = node.to_a
      target, name = arr.slice(0..1)
      args = arr.slice(2..)

      # TODO: Parse when target is not nil?
      return if target || !PARSEABLE_SENDS.include?(name)

      delegate = SEND_DISPATCH.find { |arr, del| arr.include? name }&.last
      send(delegate, node, parent, target, name, args) if delegate
    end

    def parse_module_modifier(node, parent, target, name, args)
      # FIXME: `module_function` does a lot:
      #   Creates module functions for the named methods. These functions may
      #   be called with the module as a receiver, and also become available as
      #   instance methods to classes that mix in the module. Module functions
      #   are copies of the original, and so may be changed independently. The
      #   instance-method versions are made private. If used with no arguments,
      #   subsequently defined methods become module functions. String arguments
      #   are converted to symbols.
      # ...but we will only treat it as defs, for now.
      return if args.empty? # So when nothing is provided, nothing is done.
                            # That's a poor decision by itself, but we may
                            # address this in the future.

      args.each do |a|
        handle_module_function(parent, name, a)
      end
    end

    def handle_module_function(parent, name, target)
      case target.try?(:type)
      when :def
        # This will not be ideal, but let's parse the def as a def (duh), then
        # apply the same logic of :sym here. This is as not ideal as the impl.
        # of parse_module_modifier itself.
        parse_def(target, parent)
        change_method_kind(of: target.children.first, to: :sdef, on: parent)
      when :sym
        # This moves the target from `def` to `sdef`...
        change_method_kind(of: target.children.first, to: :sdef, on: parent)
      when :string
        change_method_kind(of: target.children.first.to_sym, to: :sdef, on: parent)
      end
    end

    def parse_accessor(node, parent, target, name, args)
      parent[name] ||= []
      docs = nil
      if args.length == 1
        # When we have a single accessor, we may check for docs before it.
        docs = comments_from(node.loc.expression.first_line - 1, type: :attribute)
      end

      args.map(&:to_a).flatten.each do |n|
        parent[name].append({
          docs: docs,
          name: n,
          writer_visibility: parent[:_visibility],
          reader_visibility: parent[:_visibility]
        })
      end
    end

    def parse_class_modifier(node, parent, target, name, args)
      parent[name] ||= []
      args.each do |n|
        path, base_name = parse_class_path(n)
        parent[name].append({
          name: base_name,
          class_path: path,
        })
      end
    end

    def parse_visibility_modifier(node, parent, target, name, args)
      # Empty args changes all items defined after that point to the
      # visibility level `name`
      return parent[:_visibility] = name if args.empty?
      args.each do |a|
        handle_visibility_keyword(parent, name, a)
      end
    end

    def handle_visibility_keyword(parent, name, target)
        case target.try?(:type)
        when :def
          old_visibility = parent[:_visibility]
          parent[:_visibility] = name
          parse_def(target, parent)
          parent[:_visibility] = old_visibility

        when :defs
          old_visibility = parent[:_visibility]
          parent[:_visibility] = name
          parse_singleton_method(target, parent)
          parent[:_visibility] = old_visibility

        when :send
          # This one will be tricky... The called method can return anything,
          # so we will support at least the attr_* family.
          old_visibility = parent[:_visibility]
          parent[:_visibility] = name
          parse_send(target, parent)
          parent[:_visibility] = old_visibility

        when :sym
          # Oh no.
          change_visibility(of: target.children.first, to: name, on: parent)

        else byebug
        end
    end

    def change_visibility(of:, to:, on:)
      # Method?
      if on.key? :methods
        if (method = on[:methods].find { |m| m[:name] == of })
          return method[:visibility] = to
        end
      end

      # Accessor?
      writer = of.end_with? "="
      normalized = of.to_s.gsub(/=$/, '').to_sym
      if on.key? :attr_accessor
        if (acc = on[:attr_accessor].find { |a| a[:name] == normalized })
          if writer
            return acc[:writer_visibility] = to
          else
            return acc[:reader_visibility] = to
          end
        end
      end

      # Reader or writer?
      type = writer ? :attr_writer : :attr_reader
      if on.key? type
        if (acc = on[type].find { |a| a[:name] == normalized })
          return acc[writer ? :writer_visibility : :reader_visibility] = to
        end
      end
    end

    def change_method_kind(of:, to:, on:)
      if on.key? :methods
        if (method = on[:methods].find { |m| m[:name] == of })
          return method[:type] = to
        end
      end
    end

    def parse_def(node, parent)
      loc = node.loc.keyword
      comments = comments_from(loc.line - 1, type: :def)
      def_meta = method_to_meta(node)
      def_meta[:doc] = comments
      def_meta[:visibility] = parent ? parent[:_visibility] : :public
      if parent.nil?
        @methods << def_meta
      else
        parent[:methods] ||= []
        parent[:methods] << def_meta
      end
    end

    def parse_singleton_method(node, parent)
      loc = node.loc.keyword
      comments = comments_from(loc.line - 1, type: :defs)
      def_meta = singleton_method_to_meta(node)
      def_meta[:doc] = comments
      def_meta[:visibility] = parent ? parent[:_visibility] : :public
      if parent.nil?
        @methods << def_meta
      else
        parent[:methods] ||= []
        parent[:methods] << def_meta
      end
    end

    def parse_class(node, parent)
      loc = node.loc.keyword
      comments = comments_from(loc.line - 1, type: :class)
      class_meta = class_to_meta(node)
      class_meta[:doc] = comments
      if parent.nil?
        @classes << class_meta
      else
        parent[:classes] ||= []
        parent[:classes] << class_meta
      end
      node.to_a.slice(2...).each do |n|
        parse!(n, class_meta)
      end
    end

    def parse_singleton_class(node, parent)
      loc = node.loc.keyword
      comments = comments_from(loc.line - 1, type: :sclass)
      class_meta = singleton_class_to_meta(node)
      class_meta[:doc] = comments
      if parent.nil?
        @classes << class_meta
      else
        parent[:classes] ||= []
        parent[:classes] << class_meta
      end

      node.to_a.slice(1...).each do |n|
        parse!(n, class_meta)
      end
    end

    def parse_module(node, parent)
      loc = node.loc.keyword
      comments = comments_from(loc.line - 1, type: :module)
      module_meta = module_to_meta(node)
      module_meta[:doc] = comments
      if parent.nil?
        @modules << module_meta
      else
        parent[:modules] ||= []
        parent[:modules] << module_meta
      end

      node.to_a.slice(1...).each do |n|
        parse!(n, module_meta)
      end
    end

    def method_to_meta(node)
      {
        type: :def,
        name: node.children.first,
        args: parse_method_args(node),
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line
      }
    end

    def singleton_method_to_meta(node)
      class_path, name = parse_class_path(node.children.first)
      {
        type: :defs,
        target: name,
        class_path: class_path,
        name: node.children[1],
        args: parse_method_args(node),
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line
      }
    end

    def class_to_meta(node)
      class_path, name = parse_class_path(node.children.first)
      {
        type: :class,
        name: name,
        class_path: class_path,
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line,
        _visibility: :public,
      }.tap do |h|
        if (inherits = node.children[1])
          h[:inherits] = inherits.children.last
        end
      end
    end

    def singleton_class_to_meta(node)
      target = node.children.first.type
      target = node.children[0].children.last if target == :const
      {
        type: :sclass,
        target: target,
        _visibility: :public,
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line
      }
    end

    def module_to_meta(node)
      class_path, name = parse_class_path(node.children.first)
      {
        type: :module,
        name: name,
        _visibility: :public,
        class_path: class_path,
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line,
      }
    end

    def parse_method_args(node)
      node.children
        .find { |n| n.try?(:type) == :args }
        &.to_a
        &.map do |n|
          {
            type: n.type,
            name: n.children.first,
          }.tap do |m|
            if n.children.length > 1
              val = n.children[1]
              represented_type = nil
              represented_value = nil
              case val.type
              when :true
                represented_type = :bool
                represented_value = :true
              when :false
                represented_type = :bool
                represented_value = :false
              when :nil
                represented_type = :nil
                represented_value = :nil
              else
                represented_type = val.type
                represented_value = val.children.first
              end
              m[:value_type] = represented_type
              m[:value] = represented_value
            end
          end
        end
    end

    def parse_class_path(path)
      if path.try?(:type) == :self
        return [[], :self]
      end
      path = path.to_a
      name = path[1]
      parents = []
      parent = path.first.try?(:to_a) || []
      until parent&.empty?
        parents << parent.last
        parent = parent.first.to_a
      end
      [parents.reverse, name]
    end

    def clean_modules!
      @modules.each { |m| m.delete(:_visibility) }
    end

    def clean_classes!
      @classes.map! { |c| clean_class(c) }
    end

    def clean_class(c)
      c.delete(:_visibility)
      if c.key? :classes
        c[:classes].map! { |cl| clean_class(cl) }
      end
      c
    end
  end
end

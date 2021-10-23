# frozen_string_literal: true

module Docrb
  # RubyParser parses comments and source from a given file path and provides
  # its digested contents in standardised structures.
  class RubyParser
    COMMENT_PREFIX = /^\s*#\s?/

    attr_reader :modules, :classes, :methods, :ast

    # Initializes a new parser for a given path
    #
    # path - Path of the file to be parsed
    def initialize(path)
      @ast, @comments = ::Parser::CurrentRuby.parse_file_with_comments(path)
      @modules = []
      @classes = []
      @methods = []
    end

    # Kicks off the parsing process
    #
    # After this method is called, #modules, #classes, and #methods can be
    # used to enumerate items contained within the parsed file.
    def parse
      parse!(@ast)
      cleanup!
    end

    private

    # Recursivelly cleans modules and classes found in the parsed file by
    # removing uneeded internal fields used by the parser.
    def cleanup!
      clean_modules!
      clean_classes!
    end

    # Parses a given node and parent. This method is a dispatch source for
    # other parsing methods.
    #
    # node   - Node to be parsed
    # parent - Parent node of the node being parsed
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

    # Attempts to find a comment associated with a given line.
    #
    # line - Integer representing the line number to be checked for comments
    #
    # Returns a comment preceding the provided line, or nil, in case there's
    # none.
    def comment_for_line(line)
      return nil if line.zero? || line.negative?

      @comments.find { |c| c.loc.line == line }
    end

    # Finds and parses a comment block preceding a given line number.
    #
    # line  - Integer representing the line being processed.
    # type: - Type of node depicted in the provided line number. This is used
    #         to provide better utilities to handle the node being commented.
    #
    # Returns a hash containing the parsed comment.
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

    # Parses a `begin` keyword
    #
    # node   - The node being parsed
    # parent - The node's parent object
    def parse_begin(node, parent)
      node.children.each { |n| parse!(n, parent) }
    end

    ATTRIBUTES = %i[attr_reader attr_writer attr_accessor].freeze
    CLASS_MODIFIERS = %i[extend include].freeze
    VISIBILITY_MODIFIERS = %i[private protected public].freeze
    MODULE_MODIFIERS = [:module_function].freeze
    SEND_DISPATCH = {
      ATTRIBUTES => :parse_attribute,
      CLASS_MODIFIERS => :parse_class_modifier,
      VISIBILITY_MODIFIERS => :parse_visibility_modifier,
      MODULE_MODIFIERS => :parse_module_modifier
    }.freeze

    PARSEABLE_SENDS = [*ATTRIBUTES, *CLASS_MODIFIERS, *VISIBILITY_MODIFIERS, *MODULE_MODIFIERS].freeze

    # Parses a `send` instruction (a method call)
    #
    # node   - The node being parsed
    # parent - The node's parent object
    def parse_send(node, parent)
      arr = node.to_a
      target, name = arr.slice(0..1)
      args = arr.slice(2..)

      # TODO: Parse when target is not nil?
      return if target || !PARSEABLE_SENDS.include?(name)

      delegate = SEND_DISPATCH.find { |inner, _del| inner.include? name }&.last
      send(delegate, node, parent, target, name, args) if delegate
    end

    # Parses a module modifier. Currently this only handles a `module_function`
    # keyword.
    #
    # _node   - Unused.
    # parent  - The parent object of this modifier
    # _target - Unused.
    # name    - Name of the modifier being invoked
    # args    - Arguments passed to the modifier method
    def parse_module_modifier(_node, parent, _target, name, args)
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

    # Handles a `module_function` call and either registers and modifies a
    # function definition following it, or attempts to change previously-defined
    # functions visibility based on the call arguments.
    #
    # parent - The object on which the function has as its receiver
    # _name  - Unused.
    # target - Target object being passed to the function
    def handle_module_function(parent, _name, target)
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

    # Parses an attribute definition
    #
    # node    - The node being parsed
    # parent  - The parent containing the node being parsed
    # _target - Unused.
    # name    - Name of the attribute definer being called
    # args    - List of attribute names being defined
    def parse_attribute(node, parent, _target, name, args)
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

    # Parses a given class modifier (`include`, `extend`).
    #
    # _node   - Unused.
    # parent  - Parent object on which the modified is being called against.
    # _target - Unused.
    # name    - Name of the modifier being called.
    # args    - List of objects passed to the modifier.
    def parse_class_modifier(_node, parent, _target, name, args)
      parent[name] ||= []
      args.each do |n|
        path, base_name = parse_class_path(n)
        parent[name].append({
                              name: base_name,
                              class_path: path
                            })
      end
    end

    # Parses a given visibility modifier (`private`, `public`, `protected`) and
    # sets the current class visibility option based on whether the call
    # contains extra parameters or not. When passing names or a method
    # definition after the keyword, only listed objects are changed. Otherwise,
    # marks all subsequent objects following the keyword with its access level
    # until another modifier is found.
    #
    # _node   - Unused.
    # parent  - Parent on which the keyword is being invoked against.
    # _target - Unused.
    # name    - Name of the modifier being invoked.
    # args    - List of arguments passed to the modifier.
    def parse_visibility_modifier(_node, parent, _target, name, args)
      # Empty args changes all items defined after that point to the
      # visibility level `name`
      return parent[:_visibility] = name if args.empty?

      args.each do |a|
        handle_visibility_keyword(parent, name, a)
      end
    end

    # Handles a visibility keyword for a specific target.
    #
    # parent - Parent containing the method call.
    # name   - Name of the visibility keyword being applied
    # target - Target object on which the visibility keyword is being invoked
    #          against.
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

      else
        puts "BUG: Unexpected element on handle_visibility_keyword. Please file an issue."
        exit(1)
      end
    end

    # Changes the visibility of a single object on a given parent to a provided
    # value.
    #
    # of: - Name of the object having its visibility changed.
    # to: - New visibility value for the object.
    # on: - The object's parent container.
    def change_visibility(of:, to:, on:)
      # Method?
      if on.key?(:methods) && (method = on[:methods].find { |m| m[:name] == of })
        return method[:visibility] = to
      end

      # Accessor?
      writer = of.end_with? "="
      normalized = of.to_s.gsub(/=$/, "").to_sym
      if on.key?(:attr_accessor) && (acc = on[:attr_accessor].find { |a| a[:name] == normalized })
        return acc[writer ? :writer_visibility : :reader_visibility] = to
      end

      # Reader or writer?
      type = writer ? :attr_writer : :attr_reader
      return unless on.key?(type) && (acc = on[type].find { |a| a[:name] == normalized })

      acc[writer ? :writer_visibility : :reader_visibility] = to
    end

    # Changes the kind of a method object (E.g.: Between sdef and def)
    #
    # of: - Name of the method having its kind changed.
    # to: - New kind value for the method.
    # on: - The methods's parent container.
    def change_method_kind(of:, to:, on:)
      return unless on.key?(:methods) && (method = on[:methods].find { |m| m[:name] == of })

      method[:type] = to
    end

    # Parses an instance method definition
    #
    # node   - Node representing the method being defined
    # parent - The node's parent container (e.g. class on which it is being
    #          defined on)
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

    # Parses a class method definition
    #
    # node   - Node representing the method being defined
    # parent - The node's parent container (e.g. class on which it is being
    #          defined on)
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

    # Parses a class definition
    #
    # node   - Node representing the class being defined
    # parent - The node's parent container (e.g. class/module on which it is
    #          being defined on)
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

    # Parses a singleton class definition
    #
    # node   - Node representing the singleton class being defined
    # parent - The node's parent container (e.g. class/module on which it is
    #          being defined on)
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

    # Parses a module definition
    #
    # node   - Node representing the module being defined
    # parent - The node's parent container (e.g. class/module on which it is
    #          being defined on)
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

    # Generates metadata for a given method, such as its name, arguments,
    # and boundaries.
    #
    # node - Method node being processed
    #
    # Returns a Hash containing metadata about the provided method.
    def method_to_meta(node)
      {
        type: :def,
        name: node.children.first,
        args: parse_method_args(node),
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line
      }
    end

    # Generates metadata for a given singleton method, such as its name,
    # arguments, and boundaries.
    #
    # node - Method node being processed
    #
    # Returns a Hash containing metadata about the provided singleton method.
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

    # Generates metadata for a given class, such as its name, arguments,
    # and boundaries.
    #
    # node - Class node being processed
    #
    # Returns a Hash containing metadata about the provided class.
    def class_to_meta(node)
      class_path, name = parse_class_path(node.children.first)
      {
        type: :class,
        name: name,
        class_path: class_path,
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line,
        _visibility: :public
      }.tap do |h|
        if (inherits = node.children[1])
          h[:inherits] = inherits.children.last
        end
      end
    end

    # Generates metadata for a given singleton class, such as its name,
    # arguments, and boundaries.
    #
    # node - Singleton class node being processed
    #
    # Returns a Hash containing metadata about the provided singleton class.
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

    # Generates metadata for a given module, such as its name, arguments,
    # and boundaries.
    #
    # node - Class node being processed
    #
    # Returns a Hash containing metadata about the provided module.
    def module_to_meta(node)
      class_path, name = parse_class_path(node.children.first)
      {
        type: :module,
        name: name,
        _visibility: :public,
        class_path: class_path,
        start_at: node.loc.keyword.line,
        end_at: node.loc.end.line
      }
    end

    # Parses an argument list of a method defintion
    #
    # node - The method's node definition
    #
    # Returns a list of standardised hashes representing all method's arguments
    def parse_method_args(node)
      node.children
          .find { |n| n.try?(:type) == :args }
        &.to_a
        &.map do |n|
          {
            type: n.type,
            name: n.children.first
          }.tap do |m|
            if n.children.length > 1
              val = n.children[1]
              represented_type = nil
              represented_value = nil
              case val.type
              when true, :true
                represented_type = :bool
                represented_value = true
              when false, :false
                represented_type = :bool
                represented_value = false
              when :nil
                represented_type = :nil
                represented_value = :nil
              when :send
                represented_type = :send
                represented_value = {
                  target: parse_class_path(val.children.first).flatten.compact,
                  name: val.children.last
                }
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

    # Parses a given class path into an interable list of objects representing
    # its full path
    #
    # path - Path to be processed
    #
    # Returns a multidimensional array structure representing the path to the
    # provided value.
    def parse_class_path(path)
      return [[], :self] if path.try?(:type) == :self

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

    # Strips all contained module's structures of its internal keys used by
    # the parser.
    def clean_modules!
      @modules.each { |m| m.delete(:_visibility) }
    end

    # Recursivelly calls #clean_class for all classes contained within the
    # parser.
    def clean_classes!
      @classes.map! { |c| clean_class(c) }
    end

    # Strps the provided class structure of its internal keys used by the
    # parser.
    #
    # cls - Class structure to be cleaned.
    def clean_class(cls)
      cls.delete(:_visibility)
      cls[:classes].map! { |c| clean_class(c) } if cls.key? :classes
      cls
    end
  end
end

# frozen_string_literal: true

module Docrb
  class Parser
    class Computations
      attr_reader :parser

      def initialize(parser)
        @parser = parser
      end

      def run
        unfurl_locations
        merge_containers(parser.nodes)
        2.times { resolve_references }
        unfurl_flat_paths
        resolve_overrides
        resolve_deferred_singletons
        attach_documentation
        resolve_documentation_references
        merge_inline_documentation_blocks
        associate_container_sources
      end

      def unfurl_locations = parser.locations.each(&:load_source!)

      def unfurl_flat_paths
        parser.all_modules
          .reject { _1.path_segments.nil? || _1.path_segments.empty? }
          .each { unfurl_flat_path(_1) }

        parser.all_classes
          .reject { _1.path_segments.nil? || _1.path_segments.empty? }
          .each { unfurl_flat_path(_1) }
      end

      def unfurl_flat_path(node)
        resolve = resolve_path_partial(node.path_segments, node.parent || parser, container_only: true)
        last_found_node = resolve[:last_found_node] || parser
        if resolve[:missing_segments].empty?
          remove_from_parent!(node, parent: node.parent)
          if last_found_node.is_a? Parser
            node.parent = nil
            last_found_node.nodes.append(node)
          else
            node.parent = resolve[:last_found_node]
            if node.is_a? Class
              last_found_node.classes << node
            elsif node.is_a? Module
              last_found_node.modules << node
            end
          end

          return
        end

        # Synthesize missing segments as a Module, inject node into it.
        root = VirtualContainer.new(:module_node, resolve[:missing_segments].shift)
        parent = root
        until resolve[:missing_segments].empty?
          obj = VirtualContainer.new(:module_node, resolve[:missing_segments].shift)
          parent.body.body = [obj]
          parent = obj
        end

        if last_found_node.is_a? Parser
          obj = last_found_node.handle_node(root)
          last_found_node.nodes << obj
        else
          last_found_node.handle_node(root)
        end

        unfurl_flat_path(node)
      end

      def resolve_documentation_references
        @parser.all_objects
          .filter { _1.respond_to? :doc }
          .reject { _1.doc.nil? }
          .each do |node|
          node.doc[:value].each { resolve_documentation_reference(node, _1) }
        end
      end

      def associate_container_sources
        @parser.all_objects
          .filter { _1.is_a? Container }
          .filter { _1.defined_by.empty? }
          .each { _1.defined_by << _1.location }
      end

      def resolve_documentation_reference(node, obj)
        case obj[:type]
        when :block
          obj[:value].map! { resolve_documentation_reference node, _1 }
          obj
        when :fields
          obj[:value].transform_values! { resolve_documentation_reference(node, _1) }
          obj
        when :method_ref
          resolve_method_reference(node, obj)
        when :span, :symbol
          obj
        when :identifier
          if obj[:value].to_sym == node.try(:name)&.to_sym
            obj[:type] = :neutral_identifier
          else
            container = if node.is_a? Container
              node
            else
              find_next_container(node)
            end
            resolved = resolve_path(container, [obj[:value].to_sym])
            if resolved.respond_to?(:id)
              obj[:type] = :reference
              obj[:id] = resolved.id
              obj[:path] = path_of(resolved)
            else
              obj[:type] = :unresolved_identifier
            end
          end
          obj
        when :class_path_ref
          resolve_class_path_reference(node, obj)
        else
          puts "Unhandled documentation node #{obj[:type]}"
          obj
        end
      end

      def resolve_class_path_reference(node, ref)
        path = (ref[:class_path].gsub(/(^::|::$)/, "").split("::") + [ref[:target]]).flatten.compact.map(&:to_sym)
        node = find_next_container(node) unless node.is_a? Container
        resolved = resolve_path_partial(path, node)

        unless resolved[:missing_segments].empty?
          ref[:type] = :unresolved_identifier
          return ref
        end

        prefix = /^(::)/.match(ref[:value])&.to_a&.last
        segments = resolved[:segment_list]
        target = resolved[:last_found_node].all_objects.named(ref[:name].to_sym).first

        if target.nil?
          ref[:type] = :unresolved_identifier
          return ref
        end

        {
          type: :class_path_reference,
          prefix:,
          segments:,
          target:
        }
      end

      def resolve_method_reference(node, ref)
        return ref if ref.key? :object

        node = find_next_container(node) unless node.is_a? Container
        name = ref[:name].to_sym
        obj = if ref[:class_path]
          resolve_path(node, ref[:class_path].split("::").map(&:to_sym))
        else
          node
        end
        result = resolve_path(obj, [ref[:target], name].compact.map(&:to_sym))

        if result.nil?
          ref[:type] = :unresolved_identifier
        else
          ref[:object] = result
        end
        ref
      end

      def merge_inline_documentation_blocks
        @parser.all_objects
          .filter { _1.respond_to? :doc }
          .reject { _1.doc.nil? }
          .each { merge_inline_documentation_block(_1.doc) }
      end

      def merge_inline_documentation_block(block)
        return if !block.key?(:value) || !block[:value].is_a?(Array)

        continue = true
        while continue
          continue = false
          block[:value].each.with_index do |current, i|
            next if i.zero?

            last_i = i - 1
            last = block[:value][i - 1]
            mergeable_types = %i[netural_identifier unresolved_identifier reference]
            if mergeable_types.include?(last[:type]) && current[:type] == :text_block
              case current[:value]
              when String
                current[:value] = [last, { type: :span, value: current[:value] }]
                block[:value].delete_at(last_i)
                continue = true
                break
              when Array
                current[:value].unshift(last)
                block[:value].delete_at(last_i)
                continue = true
                break
              end
            elsif mergeable_types.include?(current[:type]) && last[:type] == :text_block
              case last[:value]
              when String
                last[:value] = [{ type: :span, value: last[:value] }, current]
                block[:value].delete_at(i)
                continue = true
                break
              when Array
                last[:value].append(current)
                block[:value].delete_at(i)
                continue = true
                break
              end
            elsif current[:type] == :text_block && last[:type] == :text_block && !current[:paragraph]
              last[:value] = [{ type: :span, value: last[:value] }] if last[:value].is_a? String
              current[:value] = [{ type: :span, value: current[:value] }] if current[:value].is_a? String
              last[:value].append(*current[:value])
              block[:value].delete_at(i)
              continue = true
              break
            end
          end
        end
      end

      def path_of(obj)
        return [] if obj.nil?

        [obj.name] + path_of(obj.parent)
      end

      def resolve_overrides
        parser.all_modules.each do |mod|
          unowned_class_methods = mod.unowned_class_methods
          mod.class_methods.each do |meth|
            next unless (other = unowned_class_methods.named(meth.name).first)

            meth.overriding = other.id
            other.overridden_by << meth.id
          end

          unowned_instance_methods = mod.unowned_instance_methods
          mod.instance_methods.each do |meth|
            next unless (other = unowned_instance_methods.named(meth.name).first)

            meth.overriding = other.id
            other.overridden_by << meth.id
          end
        end

        parser.all_classes.each do |cls|
          unowned_class_methods = cls.unowned_class_methods
          cls.class_methods.each do |meth|
            next unless (other = unowned_class_methods.named(meth.name).first)

            meth.overriding = other.id
            other.overridden_by << meth.id
          end

          unowned_instance_methods = cls.unowned_instance_methods
          cls.instance_methods.each do |meth|
            next unless (other = unowned_instance_methods.named(meth.name).first)

            meth.overriding = other.id
            other.overridden_by << meth.id
          end
        end
      end

      CONTAINER_APPENDABLE = %i[
        constants classes modules includes extends instance_methods class_methods
        instance_attributes class_attributes
      ].freeze

      def merge_containers(from)
        from.typed(Container).map(&:name).uniq.each do |n|
          list = from.named(n)
          next if list.length <= 1

          final = merge_container(list)
          from.delete_if { _1.name == n && _1 != final }
        end

        from.typed(Container).each do |container|
          CONTAINER_APPENDABLE.each do |attr|
            merge_containers(container.send(attr))
          end
        end

        true
      end

      def merge_container(list)
        list.shift.tap do |first|
          list.each do |item|
            first.defined_by << item.location if item.all_objects.any? { !_1.is_a?(Container) }
            CONTAINER_APPENDABLE.each do |attr|
              items = item.send(attr).each { _1.parent = first }
              first.send(attr).append(*items)
            end
          end
          first.defined_by << first.location if first.defined_by.empty?
        end
      end

      def remove_from_parent!(item, parent:)
        return parser.nodes.delete(item) if parent.nil?

        CONTAINER_APPENDABLE.each { parent.send(_1).delete(item) }
      end

      def resolve_references
        parser.references.reject(&:fulfilled?).each do |ref|
          target = resolve_path(ref.parent, ref.path)
          ref.resolved = if target.nil?
            ResolvedReference.new(parser, :broken, nil)
          else
            ResolvedReference.new(parser, :valid, target.id)
          end
        end
      end

      def attach_documentation
        parser.all_objects.each do |node|
          comment = case node.try(:kind)
          when :module, :class
            ([node.defined_by] + [node.location])
              .flatten
              .compact
              .uniq
              .lazy
              .map { Comment.new(parser, _1) }
              .reject { _1.comments.nil? }
              .first
          when :method
            Comment.new(parser, node.location)
          end

          next if comment.nil? || comment.comments.nil?

          node.doc = CommentParser.parse(comment.comments.join("\n"))
        end
      end

      def resolve_path(obj, path)
        p = path.dup
        obj = find_object(obj, p.shift) until p.empty? || obj.nil?
        obj
      end

      def resolve_path_partial(path, parent, container_only: false)
        path = path.dup
        if path.first == :root!
          parent = parser
          path.shift
        end

        c_filter = -> { container_only ? _1.is_a?(Container) : true }

        found_segments = []
        segment_list = []
        until path.empty?
          last_parent = parent
          if parent.is_a? Parser
            parent = parent.nodes.named(path.first).filter(&c_filter).first
            if parent.nil?
              parent = last_parent
              break
            end

            found_segments << path.shift
            segment_list << parent
            next
          end

          parent = find_object(parent, path.first, container_only:)
          if parent.nil?
            parent = last_parent
            break
          end
          found_segments << path.shift
          segment_list << parent
        end

        {
          last_found_node: parent,
          found_segments:,
          missing_segments: path,
          segment_list:
        }
      end

      def resolve_deferred_singletons
        parser.nodes.typed(DeferredSingletonClass).each do |sing|
          resolve_deferred_singleton(sing)
        end
      end

      def resolve_deferred_singleton(sing)
        object = find_object(sing.parent, sing.target, container_only: true)
        object ||= sing.parser.nodes
          .named(sing.target)
          .typed(Container)
          .reject { _1.is_a?(DeferredSingletonClass) }
          .first
        return if !object.nil? && object.kind != :class

        if object&.kind == :class
          object.merge_singleton_class(sing)
          remove_from_parent!(sing, parent: sing.parent)
          return
        end

        resolve = resolve_path_partial(sing.target, sing.parent, container_only: true)
        last_found_node = resolve[:last_found_node]
        missing_segments = resolve[:missing_segments]

        # At this point we will have to synthesize the class. Prepare its path as modules.
        class_name = missing_segments.pop
        root = if missing_segments.empty?
          parser
        else
          VirtualContainer.new(:module_node, missing_segments.shift).tap do |root|
            parent = root
            until missing_segments.empty?
              obj = VirtualContainer.new(:module_node, missing_segments.shift)
              parent.body.body = [obj]
              parent = obj
            end

            if last_found_node.is_a? Parser
              obj = last_found_node.handle_node(root)
              last_found_node.nodes << obj
            else
              last_found_node.handle_node(root)
            end
          end
        end

        cls = VirtualContainer.new(:class_node, class_name)
        cls.location = sing.location
        if root.is_a? Parser
          obj = root.handle_node(cls)
          root.nodes << obj
        else
          root.handle_node(cls)
        end

        resolve_deferred_singleton(sing)
      end

      def find_object(container, name, container_only: false)
        if container_only
          return container&.all_modules&.named(name)&.first ||
                 container&.all_classes&.named(name)&.first ||
                 (find_object(container.parent, name, container_only:) if container&.parent) ||
                 parser.nodes.lazy
                     .filter { _1.is_a?(Container) && !_1.is_a?(DeferredSingletonClass) && _1.name == name }
                     .first ||
                 parser.nodes.lazy
                     .filter { _1.is_a?(Container) && !_1.is_a?(DeferredSingletonClass) }
                     .first { find_object(_1, name, container_only:) }
        end

        container&.all_modules&.named(name)&.first ||
          container&.all_classes&.named(name)&.first ||
          container&.all_instance_methods&.named(name)&.first ||
          container&.all_instance_attributes&.named(name)&.first ||
          container&.all_class_methods&.named(name)&.first ||
          container&.all_class_attributes&.named(name)&.first ||
          (find_object(container.parent, name, container_only:) if container&.parent) ||
          parser.nodes.lazy.filter { _1.is_a?(Container) && _1.name == name }.first
      end

      def find_next_container(obj)
        return obj.parent if obj.parent.is_a? Container

        parent = obj.parent
        parent = parent.parent while parent && !parent.is_a?(Container)
        parent
      end
    end
  end
end

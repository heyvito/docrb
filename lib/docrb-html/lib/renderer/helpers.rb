class Renderer
  class Helpers
    class << self
      attr_reader :current_renderer
    end

    class << self
      attr_writer :current_renderer
    end

    def svg(name, **kwargs)
      attrs = {}
      cls = kwargs.delete(:class_name)
      title = kwargs.delete(:title)
      attrs["class"] = cls if cls && !title
      kwargs.each { |k, v| attrs[k.to_s] = v.to_s }

      svg = File.read(Renderer::ASSETS_PATH.join("images/#{name}.svg"))
      return svg if attrs.empty? && title.nil?

      doc = Nokogiri::XML svg
      attrs.each do |k, v|
        doc.css("svg")[0][k] = v
      end
      doc = doc.to_xml.split("\n").tap(&:shift).join("\n")
      return doc if title.nil?

      <<~HTML
        <div class="svg-container #{cls}">
            <div class="svg-title">#{title}</div>
            #{doc}
        </div>
      HTML
    end

    def div(class_name, **kwargs, &block)
      classes = [class_name, kwargs.delete(:class_name)].flatten.compact
      args = kwargs
        .compact
        .map { |k, v| "#{k}=\"#{v.gsub('"', "\\\"")}\"" }

      start_tag = "<div class=\"#{classes.join(" ")}\" #{args.join(" ")}>"
      end_tag = "</div>"

      fake_buffer = ""
      old_buffer = block.binding.local_variable_get(:_erbout)
      block.binding.local_variable_set(:_erbout, fake_buffer)
      raw = block.call

      captured = if fake_buffer.empty?
        raw
      else
        fake_buffer
      end
    ensure
      block.binding.local_variable_set(:_erbout, "#{start_tag}#{captured}#{end_tag}")
    end

    def capture(&block)
      fake_buffer = ""
      old_buffer = block.binding.local_variable_get(:_erbout)
      block.binding.local_variable_set(:_erbout, fake_buffer)
      raw = block.call

      captured = if fake_buffer.empty?
        raw
      else
        fake_buffer
      end
    ensure
      block.binding.local_variable_set(:_erbout, old_buffer)
    end

    def git_url(source) = self.class.current_renderer.git_url(source)

    def clean_file_path(source) = self.class.current_renderer.clean_file_path(source)

    def line_range(source)
      from = source.line_start
      to = source.line_end

      if from == to
        "line #{from}"
      else
        "lines #{from} to #{to}"
      end
    end

    def source_of(obj, parent = nil)
      parent ||= obj.parent

      case (v = parent.source_of(obj))
      when :inherited, :included, :extended then v.to_s
      when :self then ("override" if obj.try(:overriding))
      else raise "WTF? Source of #{obj} is #{v.inspect}!"
      end
    end

    def path_of(object, root: true)
      return [] if object.nil? && !root
      return [object.name] + path_of(object.parent, root: false) unless root

      path = ["#{object.name}.html"] + path_of(object.parent, root: false)
      path << ""
      path.reverse.join("/")
    end

    def link_for(object)
      case object
      when Docrb::Parser::Attribute, Docrb::Parser::Method, Docrb::Parser::Constant
        "#{path_of(object.parent)}##{anchor_for(object)}"
      when Docrb::Parser::Class, Docrb::Parser::Module
        path_of(object)
      else
        raise ArgumentError, "#link_for cannot link #{object.class.name}"
      end
    end

    def anchor_for(object)
      case object
      when Docrb::Parser::Attribute then "#{object.type}-attr-#{object.name}"
      when Docrb::Parser::Method then "#{object.type}-method-#{object.name}"
      when Docrb::Parser::Constant then "const-#{object.name}"
      when Docrb::Parser::Class, Docrb::Parser::Module then ""
      else
        raise ArgumentError, "#anchor_for cannot process #{object.class.name}"
      end
    end
  end

  Component.constants
    .reject { _1 == :HELPERS }
    .each do |cls|
    Helpers.define_method(cls.to_s.snakify) do |**kwargs|
      Component.const_get(cls).new(**kwargs).render
    end
  end

  Component.const_set(:HELPERS, Helpers.new)
end

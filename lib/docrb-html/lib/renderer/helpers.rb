class Renderer
  class Helpers
    def svg(name, **kwargs)
      attrs = {}
      cls = kwargs.delete(:class_name)
      attrs["class"] = cls if cls
      kwargs.each { |k, v| attrs[k.to_s] = v.to_s }

      svg = File.read(Renderer::ASSETS_PATH.join("images/#{name}.svg"))
      return svg if attrs.empty?

      doc = Nokogiri::XML svg
      attrs.each do |k, v|
        doc.css("svg")[0][k] = v
      end
      doc.to_xml.split("\n").tap(&:shift).join("\n")
    end

    def div(class_name, **kwargs, &block)
      classes = [class_name, kwargs.delete(:class_name)].flatten.compact
      args = kwargs
             .compact
             .map { |k, v| "#{k}=\"#{v.gsub(/"/, "\\\"")}\"" }

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

    def git_url(source) = Renderer::Defs.singleton.git_url(source)

    def clean_file_path(source) = Renderer::Defs.singleton.clean_file_path(source)

    def line_range(source)
      from = source[:start_at]
      to = source[:end_at]

      if from == to
        "line #{from}"
      else
        "lines #{from} to #{to}"
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

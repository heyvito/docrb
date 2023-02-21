# frozen_string_literal: true

class Renderer
  class Component
    attr_accessor :id

    def self.prop(*names)
      attr_accessor(*names)

      @props ||= []
      @props.append(*names)
    end

    class << self
      attr_writer :template
    end

    def self.template
      return @template_instance if @template_instance

      t_name = @template || name.split("::").last.snakify
      @template_instance = Template.new(Renderer::TEMPLATES_PATH.join("#{t_name}.erb"))
    end

    def props = @props ||= self.class.instance_variable_get(:@props) || []
    def template = self.class.template

    def initialize(**kwargs)
      @id = kwargs.delete(:id)
      kwargs.each do |k, v|
        raise ArgumentError, "Unknown property #{k} for #{self.class.name}" unless props.include? k

        send("#{k}=", v)
      end
    end

    def prepare; end

    def render(&)
      prepare
      opts = props.map { [_1, send(_1)] }.to_h
      opts[:id] = @id
      template.render(HELPERS, **opts, &)
    end
  end
end

Dir[Pathname.new(__dir__).join("component/*.rb")].each do |file|
  require_relative "component/#{Pathname.new(file).basename}"
end

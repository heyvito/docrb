# frozen_string_literal: true

module Docrb
  class DocCompiler
    def initialize(source, spec, output)
      @source = source
      @spec = spec
      @output = output
    end

    def run!
      Renderer.new(@source, @spec, @output).render
    end
  end
end

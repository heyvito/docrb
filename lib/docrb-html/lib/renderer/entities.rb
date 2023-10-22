# frozen_string_literal: true

require_relative "entities/base"
require_relative "entities/container"

require_relative "entities/method"
require_relative "entities/method_argument"
require_relative "entities/method_definition"
require_relative "entities/module"
require_relative "entities/class"
require_relative "entities/source_definition"
require_relative "entities/attribute"
require_relative "entities/attribute_definition"
require_relative "entities/reference"

class Renderer
  module Entities
    def self.current_root = Thread.current[:current_root]

    def self.current_root=(val)
      Thread.current[:current_root] = val
    end

    def self.load_from(path)
      model = JSON.load_file(path, symbolize_names: true)
      Module.new(nil, model)
        .tap(&:resolve_references!)
    end
  end
end

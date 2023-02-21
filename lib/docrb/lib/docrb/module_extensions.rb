# frozen_string_literal: true

unless Class.respond_to? :try?
  class Object
    def try?(method, *args, **kwargs, &)
      send(method, *args, **kwargs, &) if respond_to?(method)
    end

    def self.try?(method, *args, **kwargs, &)
      send(method, *args, **kwargs, &) if respond_to?(method)
    end
  end
end

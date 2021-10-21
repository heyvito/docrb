unless Class.respond_to? :try?
  class Object
    def try?(method, *args, **kwargs, &block)
      send(method, *args, **kwargs, &block) if respond_to?(method)
    end

    def self.try?(method, *args, **kwargs, &block)
      send(method, *args, **kwargs, &block) if respond_to?(method)
    end
  end
end

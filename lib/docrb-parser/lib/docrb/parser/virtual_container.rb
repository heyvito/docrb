# frozen_string_literal: true

module Docrb
  class Parser
    class VirtualContainer
      Body = Struct.new(:body)
      ConstantName = Struct.new(:name) do
        def type = :constant_read_node
      end

      attr_accessor :location, :body, :constant_path, :type, :superclass

      def initialize(type, name)
        @type = type
        @constant_path = ConstantName.new(name:)
        @location = VirtualLocation.new
        @body = Body.new(body: [])
      end
    end
  end
end

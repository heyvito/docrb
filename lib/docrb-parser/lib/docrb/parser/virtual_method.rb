# frozen_string_literal: true

module Docrb
  class Parser
    class VirtualMethod
      VirtualReceiver = Data.define(:type)

      attr_accessor :name, :parameters, :receiver

      def type = :def_node

      def initialize(name, receiver, parameters = nil)
        @name = name
        @receiver = VirtualReceiver.new(type: receiver)
        @parameters = parameters
      end
    end
  end
end

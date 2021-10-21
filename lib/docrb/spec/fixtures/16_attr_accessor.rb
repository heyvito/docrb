# frozen_string_literal: true

module Docrb
  module App
    class Test
      include Docrb::IncludeA
      include Docrb::IncludeB

      attr_accessor :foo, :bar, :baz
      attr_reader :status
      attr_writer :input
    end
  end
end

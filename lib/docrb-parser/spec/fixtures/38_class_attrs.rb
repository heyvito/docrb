class Docrb::App::Test
  include Docrb::IncludeA
  include Docrb::IncludeB

  attr_accessor :foo
  attr_accessor :bar, :baz
  attr_reader :status
  attr_writer :input
  attr_writer :explicit_reader
  attr_reader :explicit_writer

  def manually_defined = nil
  def manually_defined=(_v)
    true
  end

  def explicit_reader(_v) = true

  def explicit_writer=(_v)
    true
  end

  class << self
    attr_accessor :test

    def exp_class_accessor = :reader
    def exp_class_accessor=(value)
      :writer
    end
  end
end

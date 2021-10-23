class Docrb::App::Test
  include Docrb::IncludeA
  include Docrb::IncludeB

  attr_accessor :foo
  attr_accessor :bar, :baz
  attr_reader :status
  attr_writer :input
end

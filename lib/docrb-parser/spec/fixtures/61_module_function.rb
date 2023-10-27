module Test
  module_function def foo = :bar

  def bar = :foo

  module_function

  def baz = :bax

  public

  def instance = true

  def fox = :baz

  module_function :fox
end

module Foo
  module_function def bar
    :baz!
  end

  def fox
    :bax
  end

  module_function :fox
end

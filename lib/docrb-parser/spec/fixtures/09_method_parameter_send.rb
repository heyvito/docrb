class Foo
  def foo(something = bar)
  end

  def bar(value = SomeClass.boom)
  end

  def baz(arg = SomeModule::SomeClass.beep)
  end
end

class Foo
  def bar
  end

  def baz(something = bar)
  end

  def bax(value = SomeClass.boom)
  end

  def mem(arg = SomeModule::SomeClass.beep)
  end
end

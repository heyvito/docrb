class App
  CONST_A = :a
  CONST_B = {
    this: :is,
    const: :b,
  }
  CONST_C = CONST_B.keys.map(&:to_s)
  attr_accessor *CONST_C
end

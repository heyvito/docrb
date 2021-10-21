RSpec.describe Docrb::RubyParser do
  it "parses variadic methods" do
    parser = described_class.new(fixture_path("02_variadic_method.rb"))
    parser.parse
    expect(parser.classes).to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to_not be_empty
    expect(parser.methods.length).to eq 1
    method_meta = parser.methods.first
    expect(method_meta[:type]).to eq :def
    expect(method_meta[:name]).to eq :sum
    expect(method_meta[:args]).to eq [
      { type: :arg, name: :a },
      { type: :arg, name: :b },
      {name: :c, type: :restarg},
    ]
    expect(method_meta[:start_at]).to eq 8
    expect(method_meta[:end_at]).to eq 10
    expect(method_meta[:doc]).to_not be_nil
  end
end

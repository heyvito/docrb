RSpec.describe Docrb::RubyParser do
  it "parses simple methods" do
    parser = described_class.new(fixture_path("01_simple_method.rb"))
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
    ]
    expect(method_meta[:start_at]).to eq 7
    expect(method_meta[:end_at]).to eq 9
    expect(method_meta[:doc]).to_not be_nil
  end
end

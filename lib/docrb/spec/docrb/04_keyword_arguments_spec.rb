RSpec.describe Docrb::RubyParser do
  it "parses keyword arguments" do
    parser = described_class.new(fixture_path("04_keyword_arguments.rb"))
    parser.parse
    expect(parser.classes).to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to_not be_empty
    expect(parser.methods.length).to eq 1
    method_meta = parser.methods.first
    expect(method_meta[:type]).to eq :def
    expect(method_meta[:name]).to eq :sum
    expect(method_meta[:args]).to eq  [
      { name: :a, type: :kwarg },
      { name: :b, type: :kwarg },
      { name: :c, type: :kwarg },
    ]
    expect(method_meta[:start_at]).to eq 8
    expect(method_meta[:end_at]).to eq 10
    expect(method_meta[:doc]).to_not be_nil
  end
end

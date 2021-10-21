RSpec.describe Docrb::RubyParser do
  it "parses singleton methods" do
    parser = described_class.new(fixture_path("10_singleton_method.rb"))
    parser.parse
    expect(parser.classes).to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).not_to be_empty
    expect(parser.methods.length).to eq 1

    method_meta = parser.methods.first
    expect(method_meta).to eq({
      type: :defs,
      visibility: :public,
      target: :String,
      name: :foo,
      args: [
        {type: :arg, name: :a},
        {type: :arg, name: :b}
      ],
      class_path: [],
      start_at: 1,
      end_at: 3,
      doc: nil
    })
  end
end

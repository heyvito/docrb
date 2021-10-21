RSpec.describe Docrb::RubyParser do
  it "handles singleton classes (2)" do
    parser = described_class.new(fixture_path("12_singleton_class.rb"))
    parser.parse
    expect(parser.classes).not_to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to be_empty
    expect(parser.classes.length).to eq 1

    expect(parser.classes.first).to eq({
      type: :sclass,
      target: :String,
      start_at: 1,
      end_at: 5,
      doc: nil,
      methods: [
        {
          type: :def,
          name: :sum,
          args: [
            {type: :arg, name: :a},
            {type: :arg, name: :b}
          ],
          start_at: 2,
          end_at: 4,
          doc: nil,
          visibility: :public,
        }
      ]
    })
  end
end

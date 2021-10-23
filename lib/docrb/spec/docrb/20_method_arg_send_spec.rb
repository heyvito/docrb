# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "correctly handles calls in method arguments" do
    parser = described_class.new(fixture_path("20_method_arg_send.rb"))
    parser.parse
    expect(parser.classes.length).to be 1
    expect(parser.modules).to be_empty
    expect(parser.methods).to be_empty
    cls = parser.classes.first
    expect(cls).to eq({
      type: :class,
      name: :Foo,
      class_path: [],
      start_at: 1,
      end_at: 13,
      doc: nil,
      methods: [
        {type: :def, name: :bar, args: [], start_at: 2, end_at: 3, doc: nil, visibility: :public},
        {
          type: :def,
          name: :baz,
          args: [
            {
              type: :optarg,
              name: :something,
              value_type: :send,
              value: {
                target: [nil],
                name: :bar
              }
            }
          ],
          start_at: 5,
          end_at: 6,
          doc: nil,
          visibility: :public
        },
        {
          type: :def,
          name: :bax,
          args: [
            {
              type: :optarg,
              name: :value,
              value_type: :send,
              value: {
                target: [:SomeClass],
                name: :boom
              }
            }
          ],
          start_at: 8,
          end_at: 9,
          doc: nil,
          visibility: :public
        },
        {
          type: :def,
          name: :mem,
          args: [
            {
              type: :optarg,
              name: :arg,
              value_type: :send,
              value: {
                target: [:SomeModule, :SomeClass],
                name: :beep
              }
            }
          ],
          start_at: 11,
          end_at: 12,
          doc: nil,
          visibility: :public
        }
      ]
    })
  end
end

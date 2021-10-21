# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "honours visibility modifiers" do
    parser = described_class.new(fixture_path("17_visibility.rb"))
    parser.parse
    expect(parser.classes.first).to eq({
                                         type: :class,
                                         name: :Test,
                                         class_path: [],
                                         start_at: 1,
                                         end_at: 45,
                                         doc: nil,
                                         methods: [
                                           { type: :def, name: :pri_1, args: [], start_at: 2, end_at: 4, doc: nil,
                                             visibility: :private },
                                           { type: :def, name: :pro_1, args: [], start_at: 6, end_at: 8, doc: nil,
                                             visibility: :protected },
                                           { type: :def, name: :pub, args: [], start_at: 10, end_at: 12, doc: nil,
                                             visibility: :public },
                                           { type: :def, name: :pro_2, args: [], start_at: 16, end_at: 18, doc: nil,
                                             visibility: :protected },
                                           { type: :def, name: :pri_2, args: [], start_at: 22, end_at: 24, doc: nil,
                                             visibility: :private },
                                           { type: :def, name: :pri_3, args: [], start_at: 28, end_at: 30, doc: nil,
                                             visibility: :private },
                                           { type: :def, name: :pub_1, args: [], start_at: 34, end_at: 36, doc: nil,
                                             visibility: :public },
                                           { type: :def, name: :pri_4, args: [], start_at: 38, end_at: 40, doc: nil,
                                             visibility: :private }
                                         ],
                                         attr_accessor: [
                                           { docs: nil, name: :baz, writer_visibility: :private,
                                             reader_visibility: :private },
                                           { docs: nil, name: :foo, writer_visibility: :private,
                                             reader_visibility: :public }
                                         ]
                                       })
  end
end

# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "handles nested classes" do
    parser = described_class.new(fixture_path("18_nested_classes.rb"))
    parser.parse
    expect(parser.classes).to eq([
                                   {
                                     type: :class,
                                     name: :Foo,
                                     class_path: [],
                                     start_at: 1,
                                     end_at: 6,
                                     doc: nil,
                                     classes: [
                                       {
                                         type: :class,
                                         name: :Bar,
                                         class_path: [],
                                         start_at: 2,
                                         end_at: 5,
                                         doc: nil,
                                         methods: [
                                           {
                                             type: :def,
                                             name: :foo,
                                             args: [],
                                             start_at: 3,
                                             end_at: 4,
                                             doc: nil,
                                             visibility: :private
                                           }
                                         ]
                                       }
                                     ]
                                   }
                                 ])
  end
end

# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "handles singleton classes" do
    parser = described_class.new(fixture_path("11_singleton_class.rb"))
    parser.parse
    expect(parser.classes).not_to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to be_empty
    expect(parser.classes.length).to eq 1

    class_meta = parser.classes.first
    expect(class_meta[:type]).to eq :class
    expect(class_meta[:name]).to eq :Calculator
    expect(class_meta[:start_at]).to eq 1
    expect(class_meta[:end_at]).to eq 7
    expect(class_meta[:doc]).to eq nil

    class_meta = class_meta[:classes].first
    expect(class_meta[:type]).to eq(:sclass)
    expect(class_meta[:target]).to eq(:self)
    expect(class_meta[:start_at]).to eq(2)
    expect(class_meta[:end_at]).to eq(6)
    expect(class_meta[:doc]).to eq(nil)

    method_meta = class_meta[:methods].first
    expect(method_meta[:type]).to eq(:def)
    expect(method_meta[:name]).to eq(:sum)
    expect(method_meta[:args]).to eq [
      { type: :arg, name: :a },
      { type: :arg, name: :b }
    ]
    expect(method_meta[:start_at]).to eq(3)
    expect(method_meta[:end_at]).to eq(5)
    expect(method_meta[:doc]).to eq(nil)
  end
end

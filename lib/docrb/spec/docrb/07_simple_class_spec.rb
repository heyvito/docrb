# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "parses classes" do
    parser = described_class.new(fixture_path("07_simple_class.rb"))
    parser.parse
    expect(parser.classes).not_to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to be_empty
    expect(parser.classes.length).to eq 1

    class_meta = parser.classes.first
    expect(class_meta[:type]).to eq :class
    expect(class_meta[:name]).to eq :Calculator
    expect(class_meta[:inherits]).to eq :Object

    expect(class_meta[:start_at]).to eq 2
    expect(class_meta[:end_at]).to eq 12
    expect(class_meta[:doc]).to_not be_nil
  end
end

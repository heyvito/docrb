# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "handles module functions" do
    parser = described_class.new(fixture_path("19_module_function.rb"))
    parser.parse
    expect(parser.classes).to be_empty
    expect(parser.modules).to_not be_empty
    expect(parser.methods).to be_empty
    expect(parser.modules.length).to eq 1
    mod = parser.modules.first
    expect(mod[:methods].length).to eq 2

    method_meta = mod[:methods].first
    expect(method_meta[:type]).to eq :sdef
    expect(method_meta[:name]).to eq :bar
    expect(method_meta[:args]).to be_empty

    method_meta = mod[:methods].last
    expect(method_meta[:type]).to eq :sdef
    expect(method_meta[:name]).to eq :fox
    expect(method_meta[:args]).to be_empty
  end
end

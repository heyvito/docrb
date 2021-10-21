RSpec.describe Docrb::RubyParser do
  it "parses modules" do
    parser = described_class.new(fixture_path("08_simple_module.rb"))
    parser.parse
    expect(parser.classes).to be_empty
    expect(parser.modules).not_to be_empty
    expect(parser.methods).to be_empty
    expect(parser.modules.length).to eq 1

    module_meta = parser.modules.first
    expect(module_meta[:type]).to eq :module
    expect(module_meta[:name]).to eq :App

    expect(module_meta[:start_at]).to eq 2
    expect(module_meta[:end_at]).to eq 15
    expect(module_meta[:doc]).to_not be_nil
  end
end
